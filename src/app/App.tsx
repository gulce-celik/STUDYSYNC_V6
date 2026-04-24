import { RouterProvider } from 'react-router';
import { router } from './routes.ts';
import { Toaster } from 'sonner';

function App() {
  return (
    <>
      <RouterProvider router={router} />
      <Toaster 
        position="top-center" 
        richColors 
        toastOptions={{
          style: {
            maxWidth: '260px',
            width: '90vw',
            fontSize: '10px',
            padding: '6px 8px',
            margin: '0 auto',
            wordBreak: 'break-word',
          },
          duration: 2000,
          className: 'toast-container',
        }}
      />
    </>
  );
}

export default App;