import React from 'react';
import { render, screen } from '@testing-library/react';
import Home from '@/app/page';

jest.mock('next-auth/react', () => ({
  useSession: () => ({
    data: { user: { name: 'Test User' } },
    status: 'authenticated',
  }),
}));

jest.mock('react-dropzone', () => ({
  useDropzone: () => ({
    getRootProps: () => ({}),
    getInputProps: () => ({}),
    isDragActive: false,
  }),
}));

jest.mock('@/lib/LocaleContext', () => ({
  useLocale: () => ({ locale: 'ja', setLocale: jest.fn() }),
}));

describe('Home page', () => {
  it('renders app title via translation', () => {
    render(<Home />);
    expect(screen.getByTestId('app-title')).toBeInTheDocument();
  });

  it('renders dropzone area', () => {
    render(<Home />);
    expect(screen.getByTestId('dropzone')).toBeInTheDocument();
  });

  it('shows user status when session exists', () => {
    render(<Home />);
    expect(screen.getByTestId('user-status')).toBeInTheDocument();
  });
});
