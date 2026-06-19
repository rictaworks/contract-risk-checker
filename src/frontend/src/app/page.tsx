'use client';

import React, { useCallback } from 'react';
import { useSession } from 'next-auth/react';
import { useDropzone } from 'react-dropzone';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faFileContract, faUpload } from '@fortawesome/free-solid-svg-icons';
import { useTranslation } from '@/lib/useTranslation';
import styles from './page.module.css';

export default function Home() {
  const { data: session } = useSession();
  const { t } = useTranslation();

  const onDrop = useCallback((acceptedFiles: File[]) => {
    // 契約書ファイルアップロードのプレースホルダー
    console.log('Accepted files:', acceptedFiles);
  }, []);

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    maxSize: 10 * 1024 * 1024, // 10MB
    multiple: false
  });

  // ログイン中ユーザー名の簡易置換
  const welcomeText = t('home.welcome').replace('{name}', session?.user?.name || '');

  return (
    <div className={styles.container}>
      <header className={styles.header}>
        <h1 className={styles.title}>
          <FontAwesomeIcon icon={faFileContract} className={styles.icon} />
          {t('common.title')}
        </h1>
        {session && (
          <div className={styles.userStatus}>
            {welcomeText}
          </div>
        )}
      </header>

      <main className={styles.main}>
        <div {...getRootProps()} className={`${styles.dropzone} ${isDragActive ? styles.dropzoneActive : ''}`}>
          <input {...getInputProps()} />
          <FontAwesomeIcon icon={faUpload} className={styles.uploadIcon} />
          <p className={styles.dropzoneText}>
            {isDragActive ? t('home.dropzone_active') : t('home.dropzone_inactive')}
          </p>
          <span className={styles.fileLimit}>
            {t('home.file_limit')}
          </span>
        </div>
      </main>
    </div>
  );
}
