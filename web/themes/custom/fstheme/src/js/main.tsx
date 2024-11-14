import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import '../css/main.pcss';
import ArticleList from './components/ArticleList';

const element = document.getElementById('article-listing');
if (element) {
  const root = createRoot(element);
  root.render(
    <StrictMode>
      <>
        <ArticleList />
      </>
    </StrictMode>
  );
}

