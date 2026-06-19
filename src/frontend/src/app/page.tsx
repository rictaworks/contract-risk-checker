'use client';

import React, { useCallback } from 'react';
import { useSession } from 'next-auth/react';
import { useDropzone } from 'react-dropzone';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faFileContract, faUpload } from '@fortawesome/free-solid-svg-icons';
import { useTranslation } from '@/lib/useTranslation';
import styles from './page.module.css';

const ACCEPTED_MIME_TYPES = {
  'application/pdf': ['.pdf'],
  'text/plain': ['.txt'],
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document': ['.docx'],
};

export default function Home() {
  const { data: session } = useSession();
  const { t } = useTranslation();

  const onDrop = useCallback((acceptedFiles: File[]) => {
    console.log('Accepted files:', acceptedFiles);
  }, []);

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: ACCEPTED_MIME_TYPES,
    maxSize: 10 * 1024 * 1024,
    multiple: false,
  });

  const welcomeText = t('home.welcome').replace('{name}', session?.user?.name || '');

  return (
    <div className={styles.container}>
      <header className={styles.header}>
        <h1 className={styles.title} data-testid="app-title">
          <FontAwesomeIcon icon={faFileContract} className={styles.icon} />
          {t('common.title')}
        </h1>
        {session && (
          <div className={styles.userStatus} data-testid="user-status">
            {welcomeText}
          </div>
        )}
      </header>

      <main className={styles.main}>
        <div
          {...getRootProps()}
          className={`${styles.dropzone} ${isDragActive ? styles.dropzoneActive : ''}`}
          data-testid="dropzone"
        >
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
