module Middleware
  class RequestBodySizeLimit
    BODY_LIMIT = 8_192  # 8 KB（id_token は JWT で通常 2 KB 未満）
    AUTH_PATH = "/api/v1/auth/google"

    class LimitExceeded < StandardError; end

    # rack.input をラップし、累積読取量が BODY_LIMIT を超えたら LimitExceeded を発生させる
    class BoundedIO
      def initialize(io, limit)
        @io = io
        @limit = limit
        @bytes_read = 0
      end

      def read(length = nil, buffer = nil)
        # 下位 IO には残り上限 + 1 バイトまでしか要求しない
        remaining = @limit - @bytes_read + 1
        capped = length.nil? ? remaining : [ length, remaining ].min
        chunk = @io.read(capped, buffer)
        return chunk if chunk.nil? || chunk.empty?

        @bytes_read += chunk.bytesize
        raise LimitExceeded if @bytes_read > @limit

        chunk
      end

      def rewind
        @io.rewind
        @bytes_read = 0
      end

      def gets
        remaining = @limit - @bytes_read + 1
        chunk = @io.read(remaining)
        return nil if chunk.nil?

        @bytes_read += chunk.bytesize
        raise LimitExceeded if @bytes_read > @limit

        chunk
      end

      def each
        while (chunk = read(4096))
          yield chunk
        end
      end

      def size
        @io.respond_to?(:size) ? @io.size : nil
      end
    end

    def initialize(app)
      @app = app
    end

    def call(env)
      req = Rack::Request.new(env)
      return @app.call(env) unless req.post? && req.path.chomp("/") == AUTH_PATH

      # Content-Length 宣言チェック（高速パス）
      return payload_too_large if env["CONTENT_LENGTH"].to_i > BODY_LIMIT

      # ストリーム読取量チェック（chunked transfer や Content-Length 詐称対策）
      env["rack.input"] = BoundedIO.new(env["rack.input"], BODY_LIMIT)
      @app.call(env)
    rescue LimitExceeded
      payload_too_large
    end

    private

    def payload_too_large
      [ 413, { "Content-Type" => "application/json" }, [ '{"error":"Payload Too Large"}' ] ]
    end
  end
end

Rails.application.config.middleware.insert_before(Rack::Attack, Middleware::RequestBodySizeLimit)
