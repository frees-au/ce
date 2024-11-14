import { useEffect, useState } from "react";
import ReactPaginate from "react-paginate";

const search_api = window.searchApiJs;
const article_index = search_api.getServer('lunr').getIndex('article');

interface IndexItem {
  fields: Array<{id: String, settings: {boost: number}}>,
  id: String,
  rawDocument: {
    title: String,
    url: String,
    lead: String,
    rendered_item: String,
    created: String,
  }
}

export default function ArticleList() {
  const [items, setItems] = useState<IndexItem[]>([]);
  const [itemOffset, setItemOffset] = useState(0);
  const [searchString, setSearchString] = useState('');

  const itemsPerPage = 6;
  const endOffset = itemOffset + itemsPerPage;
  const currentItems = items.slice(itemOffset, endOffset);
  const pageCount = Math.ceil(items.length / itemsPerPage);
  const sortByCreated = ((item1: IndexItem, item2: IndexItem) => {
    return Number(item2.rawDocument.created) - Number(item1.rawDocument.created);
  });
  
  useEffect(() => {
    article_index.search(searchString).then((results: IndexItem[]) => {
      results.sort(sortByCreated);
      setItems(results);
    });
  }, []);

  const handlePageClick = (event: {selected: number}) => {
    const newOffset = (event.selected * itemsPerPage) % items.length;
    setItemOffset(newOffset);
  };

  const handleSubmitSearch = ((e: React.FormEvent) => {
    e.preventDefault();
    article_index.search(searchString).then((results: IndexItem[]) => {
      setItems(results);
      setItemOffset(0);
    });
  });

  return (
    <>
      <form onSubmit={handleSubmitSearch}>
        <div className="flex">
          <input placeholder="Search Content" className="p-[16px] border-2 rounded-l-md border-[#bfbfbf] border-r-0 w-full" type="text" value={searchString} name="s" onChange={(e: React.ChangeEvent<HTMLInputElement>) => { setSearchString(e.target.value) }}/>
          <button className="border-2 border-[#bfbfbf] rounded-r-md bg-fs-red-tint border-l-0 text-white py-[16px] px-[24px]">
            <svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M18.4444 20L11.4444 13C10.8889 13.4444 10.25 13.7963 9.52778 14.0556C8.80556 14.3148 8.03704 14.4444 7.22222 14.4444C5.2037 14.4444 3.49537 13.7454 2.09722 12.3472C0.699074 10.9491 0 9.24074 0 7.22222C0 5.2037 0.699074 3.49537 2.09722 2.09722C3.49537 0.699074 5.2037 0 7.22222 0C9.24074 0 10.9491 0.699074 12.3472 2.09722C13.7454 3.49537 14.4444 5.2037 14.4444 7.22222C14.4444 8.03704 14.3148 8.80556 14.0556 9.52778C13.7963 10.25 13.4444 10.8889 13 11.4444L20 18.4444L18.4444 20ZM7.22222 12.2222C8.61111 12.2222 9.79167 11.7361 10.7639 10.7639C11.7361 9.79167 12.2222 8.61111 12.2222 7.22222C12.2222 5.83333 11.7361 4.65278 10.7639 3.68056C9.79167 2.70833 8.61111 2.22222 7.22222 2.22222C5.83333 2.22222 4.65278 2.70833 3.68056 3.68056C2.70833 4.65278 2.22222 5.83333 2.22222 7.22222C2.22222 8.61111 2.70833 9.79167 3.68056 10.7639C4.65278 11.7361 5.83333 12.2222 7.22222 12.2222Z" fill="white"/>
            </svg>
          </button>
        </div>
      </form>
      <p>{items.length} results</p>
      <div className="items grid gap-x-3 gap-y-6 grid-cols-1 md:grid-cols-2 lg:grid-cols-3 font-sans">
        { currentItems.map((item, key) => {
          return (
            <div key={key} className="item">
              <div className="h-full" dangerouslySetInnerHTML={{ __html: item.rawDocument.rendered_item }} />
            </div>
          );
        }) }
      </div>
      <ReactPaginate
        containerClassName="pager flex justify-center mt-[80px] font-sans leading-[27px]"
        breakLabel="..."
        nextLabel=">"
        onPageChange={handlePageClick}
        pageRangeDisplayed={5}
        pageCount={pageCount}
        previousLabel="<"
        pageLinkClassName="p-[5px]"
        activeLinkClassName="text-fs-red"
        disabledClassName="disabled hidden"
        previousLinkClassName="p-[5px]"
        nextLinkClassName="p-[5px]"
      />
    </>
  );
}
