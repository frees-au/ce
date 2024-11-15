import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import ArticleList from './components/ArticleList';

const elements = document.querySelectorAll('.article-list');

elements.forEach((element) => {
  const root = createRoot(element);
  root.render(
    <StrictMode>
      <>
        <ArticleList />
      </>
    </StrictMode>
  );
})
