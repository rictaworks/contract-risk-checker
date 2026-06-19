import React from 'react';
import { render, screen } from '@testing-library/react';
import Home from '@/app/page';

// next-auth/react の useSession をモック
jest.mock('next-auth/react', () => ({
  useSession: () => ({
    data: { user: { name: 'テストユーザー' } },
    status: 'authenticated',
  }),
}));

// react-dropzone のモック
jest.mock('react-dropzone', () => ({
  useDropzone: () => ({
    getRootProps: () => ({}),
    getInputProps: () => ({}),
    isDragActive: false,
  }),
}));

describe('Home page', () => {
  it('renders without crashing and displays localized title', () => {
    render(<Home />);
    
    // タイトルがレンダリングされているか確認
    expect(screen.getByText('契約リスクチェッカー')).toBeInTheDocument();
    
    // ユーザーセッション情報がレンダリングされているか確認
    expect(screen.getByText('ログイン中: テストユーザー')).toBeInTheDocument();
  });
});
