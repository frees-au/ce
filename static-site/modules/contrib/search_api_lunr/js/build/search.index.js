import{a as e}from"./_commonjsHelpers-7894710e.js";var t=Object.prototype.hasOwnProperty,a=Array.isArray,r=function(){for(var e=[],t=0;t<256;++t)e.push("%"+((t<16?"0":"")+t.toString(16)).toUpperCase());return e}(),i=function(e,t){for(var a=t&&t.plainObjects?Object.create(null):{},r=0;r<e.length;++r)void 0!==e[r]&&(a[r]=e[r]);return a},o={arrayToObject:i,assign:function(e,t){return Object.keys(t).reduce((function(e,a){return e[a]=t[a],e}),e)},combine:function(e,t){return[].concat(e,t)},compact:function(e){for(var t=[{obj:{o:e},prop:"o"}],r=[],i=0;i<t.length;++i)for(var o=t[i],n=o.obj[o.prop],s=Object.keys(n),l=0;l<s.length;++l){var c=s[l],u=n[c];"object"==typeof u&&null!==u&&-1===r.indexOf(u)&&(t.push({obj:n,prop:c}),r.push(u))}return function(e){for(;e.length>1;){var t=e.pop(),r=t.obj[t.prop];if(a(r)){for(var i=[],o=0;o<r.length;++o)void 0!==r[o]&&i.push(r[o]);t.obj[t.prop]=i}}}(t),e},decode:function(e,t,a){var r=e.replace(/\+/g," ");if("iso-8859-1"===a)return r.replace(/%[0-9a-f]{2}/gi,unescape);try{return decodeURIComponent(r)}catch(e){return r}},encode:function(e,t,a){if(0===e.length)return e;var i=e;if("symbol"==typeof e?i=Symbol.prototype.toString.call(e):"string"!=typeof e&&(i=String(e)),"iso-8859-1"===a)return escape(i).replace(/%u[0-9a-f]{4}/gi,(function(e){return"%26%23"+parseInt(e.slice(2),16)+"%3B"}));for(var o="",n=0;n<i.length;++n){var s=i.charCodeAt(n);45===s||46===s||95===s||126===s||s>=48&&s<=57||s>=65&&s<=90||s>=97&&s<=122?o+=i.charAt(n):s<128?o+=r[s]:s<2048?o+=r[192|s>>6]+r[128|63&s]:s<55296||s>=57344?o+=r[224|s>>12]+r[128|s>>6&63]+r[128|63&s]:(n+=1,s=65536+((1023&s)<<10|1023&i.charCodeAt(n)),o+=r[240|s>>18]+r[128|s>>12&63]+r[128|s>>6&63]+r[128|63&s])}return o},isBuffer:function(e){return!(!e||"object"!=typeof e)&&!!(e.constructor&&e.constructor.isBuffer&&e.constructor.isBuffer(e))},isRegExp:function(e){return"[object RegExp]"===Object.prototype.toString.call(e)},merge:function e(r,o,n){if(!o)return r;if("object"!=typeof o){if(a(r))r.push(o);else{if(!r||"object"!=typeof r)return[r,o];(n&&(n.plainObjects||n.allowPrototypes)||!t.call(Object.prototype,o))&&(r[o]=!0)}return r}if(!r||"object"!=typeof r)return[r].concat(o);var s=r;return a(r)&&!a(o)&&(s=i(r,n)),a(r)&&a(o)?(o.forEach((function(a,i){if(t.call(r,i)){var o=r[i];o&&"object"==typeof o&&a&&"object"==typeof a?r[i]=e(o,a,n):r.push(a)}else r[i]=a})),r):Object.keys(o).reduce((function(a,r){var i=o[r];return t.call(a,r)?a[r]=e(a[r],i,n):a[r]=i,a}),s)}},n=String.prototype.replace,s=/%20/g,l={RFC1738:"RFC1738",RFC3986:"RFC3986"},c=o.assign({default:l.RFC3986,formatters:{RFC1738:function(e){return n.call(e,s,"+")},RFC3986:function(e){return String(e)}}},l),u=(Object.prototype.hasOwnProperty,Array.isArray,Array.prototype.push,Date.prototype.toISOString),p=c.default,g=(c.formatters[p],Object.prototype.hasOwnProperty),f=Array.isArray,d={allowDots:!1,allowPrototypes:!1,arrayLimit:20,charset:"utf-8",charsetSentinel:!1,comma:!1,decoder:o.decode,delimiter:"&",depth:5,ignoreQueryPrefix:!1,interpretNumericEntities:!1,parameterLimit:1e3,parseArrays:!0,plainObjects:!1,strictNullHandling:!1},m=function(e){return e.replace(/&#(\d+);/g,(function(e,t){return String.fromCharCode(parseInt(t,10))}))},h=function(e,t){return e&&"string"==typeof e&&t.comma&&e.indexOf(",")>-1?e.split(","):e},b=function(e,t){if(f(e)){for(var a=[],r=0;r<e.length;r+=1)a.push(t(e[r]));return a}return t(e)},y=function(e,t,a,r){if(e){var i=a.allowDots?e.replace(/\.([^.[]+)/g,"[$1]"):e,o=/(\[[^[\]]*])/g,n=a.depth>0&&/(\[[^[\]]*])/.exec(i),s=n?i.slice(0,n.index):i,l=[];if(s){if(!a.plainObjects&&g.call(Object.prototype,s)&&!a.allowPrototypes)return;l.push(s)}for(var c=0;a.depth>0&&null!==(n=o.exec(i))&&c<a.depth;){if(c+=1,!a.plainObjects&&g.call(Object.prototype,n[1].slice(1,-1))&&!a.allowPrototypes)return;l.push(n[1])}return n&&l.push("["+i.slice(n.index)+"]"),function(e,t,a,r){for(var i=r?t:h(t,a),o=e.length-1;o>=0;--o){var n,s=e[o];if("[]"===s&&a.parseArrays)n=[].concat(i);else{n=a.plainObjects?Object.create(null):{};var l="["===s.charAt(0)&&"]"===s.charAt(s.length-1)?s.slice(1,-1):s,c=parseInt(l,10);a.parseArrays||""!==l?!isNaN(c)&&s!==l&&String(c)===l&&c>=0&&a.parseArrays&&c<=a.arrayLimit?(n=[])[c]=i:n[l]=i:n={0:i}}i=n}return i}(l,t,a,r)}},v=function(e,t){var a=function(e){if(!e)return d;if(null!==e.decoder&&void 0!==e.decoder&&"function"!=typeof e.decoder)throw new TypeError("Decoder has to be a function.");if(void 0!==e.charset&&"utf-8"!==e.charset&&"iso-8859-1"!==e.charset)throw new TypeError("The charset option must be either utf-8, iso-8859-1, or undefined");var t=void 0===e.charset?d.charset:e.charset;return{allowDots:void 0===e.allowDots?d.allowDots:!!e.allowDots,allowPrototypes:"boolean"==typeof e.allowPrototypes?e.allowPrototypes:d.allowPrototypes,arrayLimit:"number"==typeof e.arrayLimit?e.arrayLimit:d.arrayLimit,charset:t,charsetSentinel:"boolean"==typeof e.charsetSentinel?e.charsetSentinel:d.charsetSentinel,comma:"boolean"==typeof e.comma?e.comma:d.comma,decoder:"function"==typeof e.decoder?e.decoder:d.decoder,delimiter:"string"==typeof e.delimiter||o.isRegExp(e.delimiter)?e.delimiter:d.delimiter,depth:"number"==typeof e.depth||!1===e.depth?+e.depth:d.depth,ignoreQueryPrefix:!0===e.ignoreQueryPrefix,interpretNumericEntities:"boolean"==typeof e.interpretNumericEntities?e.interpretNumericEntities:d.interpretNumericEntities,parameterLimit:"number"==typeof e.parameterLimit?e.parameterLimit:d.parameterLimit,parseArrays:!1!==e.parseArrays,plainObjects:"boolean"==typeof e.plainObjects?e.plainObjects:d.plainObjects,strictNullHandling:"boolean"==typeof e.strictNullHandling?e.strictNullHandling:d.strictNullHandling}}(t);if(""===e||null==e)return a.plainObjects?Object.create(null):{};for(var r="string"==typeof e?function(e,t){var a,r={},i=t.ignoreQueryPrefix?e.replace(/^\?/,""):e,n=t.parameterLimit===1/0?void 0:t.parameterLimit,s=i.split(t.delimiter,n),l=-1,c=t.charset;if(t.charsetSentinel)for(a=0;a<s.length;++a)0===s[a].indexOf("utf8=")&&("utf8=%E2%9C%93"===s[a]?c="utf-8":"utf8=%26%2310003%3B"===s[a]&&(c="iso-8859-1"),l=a,a=s.length);for(a=0;a<s.length;++a)if(a!==l){var u,p,y=s[a],v=y.indexOf("]="),N=-1===v?y.indexOf("="):v+1;-1===N?(u=t.decoder(y,d.decoder,c,"key"),p=t.strictNullHandling?null:""):(u=t.decoder(y.slice(0,N),d.decoder,c,"key"),p=b(h(y.slice(N+1),t),(function(e){return t.decoder(e,d.decoder,c,"value")}))),p&&t.interpretNumericEntities&&"iso-8859-1"===c&&(p=m(p)),y.indexOf("[]=")>-1&&(p=f(p)?[p]:p),g.call(r,u)?r[u]=o.combine(r[u],p):r[u]=p}return r}(e,a):e,i=a.plainObjects?Object.create(null):{},n=Object.keys(r),s=0;s<n.length;++s){var l=n[s],c=y(l,r[l],a,"string"==typeof e);i=o.merge(i,c,a)}return o.compact(i)};!function(e,t){void 0===t&&o("Pagination requires jQuery.");var a="pagination",r="__pagination-";t.fn.pagination&&(a="pagination2"),t.fn[a]=function(l){if(void 0===l)return this;var c=t(this),u=t.extend({},t.fn[a].defaults,l),p={initialize:function(){var e=this;if(c.data("pagination")||c.data("pagination",{}),!1!==e.callHook("beforeInit")){c.data("pagination").initialized&&t(".paginationjs",c).remove(),e.disabled=!!u.disabled;var a=e.model={pageRange:u.pageRange,pageSize:u.pageSize};e.parseDataSource(u.dataSource,(function(t){e.isAsync=i.isString(t),i.isArray(t)&&(a.totalNumber=u.totalNumber=t.length),e.isDynamicTotalNumber=e.isAsync&&u.totalNumberLocator;var r=e.render(!0);u.className&&r.addClass(u.className),a.el=r,c["bottom"===u.position?"append":"prepend"](r),e.observer(),c.data("pagination").initialized=!0,e.callHook("afterInit",r)}))}},render:function(e){var a=this.model,r=a.el||t('<div class="paginationjs"></div>'),i=!0!==e;this.callHook("beforeRender",i);var o=a.pageNumber||u.pageNumber,n=u.pageRange||0,s=this.getTotalPage(),l=o-n,c=o+n;return c>s&&(c=s,l=(l=s-2*n)<1?1:l),l<=1&&(l=1,c=Math.min(2*n+1,s)),r.html(this.generateHTML({currentPage:o,pageRange:n,rangeStart:l,rangeEnd:c})),u.hideWhenLessThanOnePage&&r[s<=1?"hide":"show"](),this.callHook("afterRender",i),r},generatePageNumbersHTML:function(e){var t,a=e.currentPage,r=this.getTotalPage(),i=e.rangeStart,o=e.rangeEnd,n="",s=u.pageLink,l=u.ellipsisText,c=u.classPrefix,p=u.activeClassName,g=u.disableClassName;if(null===u.pageRange){for(t=1;t<=r;t++)n+=t==a?'<li class="'+c+"-page J-paginationjs-page "+p+'" data-num="'+t+'"><a>'+t+"</a></li>":'<li class="'+c+'-page J-paginationjs-page" data-num="'+t+'"><a href="'+s+'">'+t+"</a></li>";return n}if(i<=3)for(t=1;t<i;t++)n+=t==a?'<li class="'+c+"-page J-paginationjs-page "+p+'" data-num="'+t+'"><a>'+t+"</a></li>":'<li class="'+c+'-page J-paginationjs-page" data-num="'+t+'"><a href="'+s+'">'+t+"</a></li>";else u.showFirstOnEllipsisShow&&(n+='<li class="'+c+"-page "+c+'-first J-paginationjs-page" data-num="1"><a href="'+s+'">1</a></li>'),n+='<li class="'+c+"-ellipsis "+g+'"><a>'+l+"</a></li>";for(t=i;t<=o;t++)n+=t==a?'<li class="'+c+"-page J-paginationjs-page "+p+'" data-num="'+t+'"><a>'+t+"</a></li>":'<li class="'+c+'-page J-paginationjs-page" data-num="'+t+'"><a href="'+s+'">'+t+"</a></li>";if(o>=r-2)for(t=o+1;t<=r;t++)n+='<li class="'+c+'-page J-paginationjs-page" data-num="'+t+'"><a href="'+s+'">'+t+"</a></li>";else n+='<li class="'+c+"-ellipsis "+g+'"><a>'+l+"</a></li>",u.showLastOnEllipsisShow&&(n+='<li class="'+c+"-page "+c+'-last J-paginationjs-page" data-num="'+r+'"><a href="'+s+'">'+r+"</a></li>");return n},generateHTML:function(e){var a=e.currentPage,r=this.getTotalPage(),i=this.getTotalNumber(),o=u.showPrevious,n=u.showNext,s=u.showPageNumbers,l=u.showNavigator,c=u.showGoInput,p=u.showGoButton,g=u.pageLink,f=u.prevText,d=u.nextText,m=u.goButtonText,h=u.classPrefix,b=u.disableClassName,y=u.ulClassName,v="",N='<input type="text" class="J-paginationjs-go-pagenumber">',j='<input type="button" class="J-paginationjs-go-button" value="'+m+'">',P=t.isFunction(u.formatNavigator)?u.formatNavigator(a,r,i):u.formatNavigator,k=t.isFunction(u.formatGoInput)?u.formatGoInput(N,a,r,i):u.formatGoInput,w=t.isFunction(u.formatGoButton)?u.formatGoButton(j,a,r,i):u.formatGoButton,x=t.isFunction(u.autoHidePrevious)?u.autoHidePrevious():u.autoHidePrevious,O=t.isFunction(u.autoHideNext)?u.autoHideNext():u.autoHideNext,S=t.isFunction(u.header)?u.header(a,r,i):u.header,L=t.isFunction(u.footer)?u.footer(a,r,i):u.footer;return S&&(v+=this.replaceVariables(S,{currentPage:a,totalPage:r,totalNumber:i})),(o||s||n)&&(v+='<div class="paginationjs-pages">',v+=y?'<ul class="'+y+'">':"<ul>",o&&(a<=1?x||(v+='<li class="'+h+"-prev "+b+'"><a>'+f+"</a></li>"):v+='<li class="'+h+'-prev J-paginationjs-previous" data-num="'+(a-1)+'" title="Previous page"><a href="'+g+'">'+f+"</a></li>"),s&&(v+=this.generatePageNumbersHTML(e)),n&&(a>=r?O||(v+='<li class="'+h+"-next "+b+'"><a>'+d+"</a></li>"):v+='<li class="'+h+'-next J-paginationjs-next" data-num="'+(a+1)+'" title="Next page"><a href="'+g+'">'+d+"</a></li>"),v+="</ul></div>"),l&&P&&(v+='<div class="'+h+'-nav J-paginationjs-nav">'+this.replaceVariables(P,{currentPage:a,totalPage:r,totalNumber:i})+"</div>"),c&&k&&(v+='<div class="'+h+'-go-input">'+this.replaceVariables(k,{currentPage:a,totalPage:r,totalNumber:i,input:N})+"</div>"),p&&w&&(v+='<div class="'+h+'-go-button">'+this.replaceVariables(w,{currentPage:a,totalPage:r,totalNumber:i,button:j})+"</div>"),L&&(v+=this.replaceVariables(L,{currentPage:a,totalPage:r,totalNumber:i})),v},findTotalNumberFromRemoteResponse:function(e){this.model.totalNumber=u.totalNumberLocator(e)},go:function(e,a){var r=this,o=r.model;if(!r.disabled){var n=e;if((n=parseInt(n))&&!(n<1)){var s=u.pageSize,l=r.getTotalNumber(),p=r.getTotalPage();if(!(l>0&&n>p))if(r.isAsync){var g={},f=u.alias||{};g[f.pageSize?f.pageSize:"pageSize"]=s,g[f.pageNumber?f.pageNumber:"pageNumber"]=n;var d=t.isFunction(u.ajax)?u.ajax():u.ajax,m={type:"get",cache:!1,data:{},contentType:"application/x-www-form-urlencoded; charset=UTF-8",dataType:"json",async:!0};t.extend(!0,m,d),t.extend(m.data,g),m.url=u.dataSource,m.success=function(e){r.isDynamicTotalNumber?r.findTotalNumberFromRemoteResponse(e):r.model.totalNumber=u.totalNumber,h(r.filterDataByLocator(e))},m.error=function(e,t,a){u.formatAjaxError&&u.formatAjaxError(e,t,a),r.enable()},r.disable(),t.ajax(m)}else h(r.getDataFragment(n))}}function h(e){if(!1===r.callHook("beforePaging",n))return!1;if(o.direction=void 0===o.pageNumber?0:n>o.pageNumber?1:-1,o.pageNumber=n,r.render(),r.disabled&&r.isAsync&&r.enable(),c.data("pagination").model=o,u.formatResult){var s=t.extend(!0,[],e);i.isArray(e=u.formatResult(s))||(e=s)}c.data("pagination").currentPageData=e,r.doCallback(e,a),r.callHook("afterPaging",n),1==n&&r.callHook("afterIsFirstPage"),n==r.getTotalPage()&&r.callHook("afterIsLastPage")}},doCallback:function(e,a){var r=this.model;t.isFunction(a)?a(e,r):t.isFunction(u.callback)&&u.callback(e,r)},destroy:function(){!1!==this.callHook("beforeDestroy")&&(this.model.el.remove(),c.off(),t("#paginationjs-style").remove(),this.callHook("afterDestroy"))},previous:function(e){this.go(this.model.pageNumber-1,e)},next:function(e){this.go(this.model.pageNumber+1,e)},disable:function(){var e=this.isAsync?"async":"sync";!1!==this.callHook("beforeDisable",e)&&(this.disabled=!0,this.model.disabled=!0,this.callHook("afterDisable",e))},enable:function(){var e=this.isAsync?"async":"sync";!1!==this.callHook("beforeEnable",e)&&(this.disabled=!1,this.model.disabled=!1,this.callHook("afterEnable",e))},refresh:function(e){this.go(this.model.pageNumber,e)},show:function(){this.model.el.is(":visible")||this.model.el.show()},hide:function(){this.model.el.is(":visible")&&this.model.el.hide()},replaceVariables:function(e,t){var a;for(var r in t){var i=t[r],o=new RegExp("<%=\\s*"+r+"\\s*%>","img");a=(a||e).replace(o,i)}return a},getDataFragment:function(e){var t=u.pageSize,a=u.dataSource,r=this.getTotalNumber(),i=t*(e-1)+1,o=Math.min(e*t,r);return a.slice(i-1,o)},getTotalNumber:function(){return this.model.totalNumber||u.totalNumber||0},getTotalPage:function(){return Math.ceil(this.getTotalNumber()/u.pageSize)},getLocator:function(e){var a;return"string"==typeof e?a=e:t.isFunction(e)?a=e():o('"locator" is incorrect. (String | Function)'),a},filterDataByLocator:function(e){var a,r=this.getLocator(u.locator);if(i.isObject(e)){try{t.each(r.split("."),(function(t,r){a=(a||e)[r]}))}catch(e){}a?i.isArray(a)||o("dataSource."+r+" must be an Array."):o("dataSource."+r+" is undefined.")}return a||e},parseDataSource:function(e,a){var r=this;i.isObject(e)?a(u.dataSource=r.filterDataByLocator(e)):i.isArray(e)?a(u.dataSource=e):t.isFunction(e)?u.dataSource((function(e){i.isArray(e)||o('The parameter of "done" Function should be an Array.'),r.parseDataSource.call(r,e,a)})):"string"==typeof e?(/^https?|file:/.test(e)&&(u.ajaxDataType="jsonp"),a(e)):o('Unexpected type of "dataSource".')},callHook:function(a){var r,i=c.data("pagination"),o=Array.prototype.slice.apply(arguments);return o.shift(),u[a]&&t.isFunction(u[a])&&!1===u[a].apply(e,o)&&(r=!1),i.hooks&&i.hooks[a]&&t.each(i.hooks[a],(function(t,a){!1===a.apply(e,o)&&(r=!1)})),!1!==r},observer:function(){var e=this,a=e.model.el;c.on(r+"go",(function(a,r,i){(r=parseInt(t.trim(r)))&&(t.isNumeric(r)||o('"pageNumber" is incorrect. (Number)'),e.go(r,i))})),a.delegate(".J-paginationjs-page","click",(function(a){var r=t(a.currentTarget),i=t.trim(r.attr("data-num"));if(i&&!r.hasClass(u.disableClassName)&&!r.hasClass(u.activeClassName))return!1!==e.callHook("beforePageOnClick",a,i)&&(e.go(i),e.callHook("afterPageOnClick",a,i),!!u.pageLink&&void 0)})),a.delegate(".J-paginationjs-previous","click",(function(a){var r=t(a.currentTarget),i=t.trim(r.attr("data-num"));if(i&&!r.hasClass(u.disableClassName))return!1!==e.callHook("beforePreviousOnClick",a,i)&&(e.go(i),e.callHook("afterPreviousOnClick",a,i),!!u.pageLink&&void 0)})),a.delegate(".J-paginationjs-next","click",(function(a){var r=t(a.currentTarget),i=t.trim(r.attr("data-num"));if(i&&!r.hasClass(u.disableClassName))return!1!==e.callHook("beforeNextOnClick",a,i)&&(e.go(i),e.callHook("afterNextOnClick",a,i),!!u.pageLink&&void 0)})),a.delegate(".J-paginationjs-go-button","click",(function(i){var o=t(".J-paginationjs-go-pagenumber",a).val();if(!1===e.callHook("beforeGoButtonOnClick",i,o))return!1;c.trigger(r+"go",o),e.callHook("afterGoButtonOnClick",i,o)})),a.delegate(".J-paginationjs-go-pagenumber","keyup",(function(i){if(13===i.which){var o=t(i.currentTarget).val();if(!1===e.callHook("beforeGoInputOnEnter",i,o))return!1;c.trigger(r+"go",o),t(".J-paginationjs-go-pagenumber",a).focus(),e.callHook("afterGoInputOnEnter",i,o)}})),c.on(r+"previous",(function(t,a){e.previous(a)})),c.on(r+"next",(function(t,a){e.next(a)})),c.on(r+"disable",(function(){e.disable()})),c.on(r+"enable",(function(){e.enable()})),c.on(r+"refresh",(function(t,a){e.refresh(a)})),c.on(r+"show",(function(){e.show()})),c.on(r+"hide",(function(){e.hide()})),c.on(r+"destroy",(function(){e.destroy()}));var i=Math.max(e.getTotalPage(),1),n=u.pageNumber;e.isDynamicTotalNumber&&(n=1),u.triggerPagingOnInit&&c.trigger(r+"go",Math.min(n,i))}};if(c.data("pagination")&&!0===c.data("pagination").initialized){if(t.isNumeric(l))return c.trigger.call(this,r+"go",l,arguments[1]),this;if("string"==typeof l){var g=Array.prototype.slice.apply(arguments);switch(g[0]=r+g[0],l){case"previous":case"next":case"go":case"disable":case"enable":case"refresh":case"show":case"hide":case"destroy":c.trigger.apply(this,g);break;case"getSelectedPageNum":return c.data("pagination").model?c.data("pagination").model.pageNumber:c.data("pagination").attributes.pageNumber;case"getTotalPage":return Math.ceil(c.data("pagination").model.totalNumber/c.data("pagination").model.pageSize);case"getSelectedPageData":return c.data("pagination").currentPageData;case"isDisabled":return!0===c.data("pagination").model.disabled;default:o("Unknown action: "+l)}return this}s(c)}else i.isObject(l)||o("Illegal options");return n(u),p.initialize(),this},t.fn[a].defaults={totalNumber:0,pageNumber:1,pageSize:10,pageRange:2,showPrevious:!0,showNext:!0,showPageNumbers:!0,showNavigator:!1,showGoInput:!1,showGoButton:!1,pageLink:"",prevText:"&laquo;",nextText:"&raquo;",ellipsisText:"...",goButtonText:"Go",classPrefix:"paginationjs",activeClassName:"active",disableClassName:"disabled",inlineStyle:!0,formatNavigator:"<%= currentPage %> / <%= totalPage %>",formatGoInput:"<%= input %>",formatGoButton:"<%= button %>",position:"bottom",autoHidePrevious:!1,autoHideNext:!1,triggerPagingOnInit:!0,hideWhenLessThanOnePage:!1,showFirstOnEllipsisShow:!0,showLastOnEllipsisShow:!0,callback:function(){}},t.fn.addHook=function(e,a){arguments.length<2&&o("Missing argument."),t.isFunction(a)||o("callback must be a function.");var r=t(this),i=r.data("pagination");i||(r.data("pagination",{}),i=r.data("pagination")),!i.hooks&&(i.hooks={}),i.hooks[e]=i.hooks[e]||[],i.hooks[e].push(a)},t[a]=function(e,a){var r;if(arguments.length<2&&o("Requires two parameters."),(r="string"!=typeof e&&e instanceof jQuery?e:t(e)).length)return r.pagination(a),r};var i={};function o(e){throw new Error("Pagination: "+e)}function n(e){e.dataSource||o('"dataSource" is required.'),"string"==typeof e.dataSource?void 0===e.totalNumberLocator?void 0===e.totalNumber?o('"totalNumber" is required.'):t.isNumeric(e.totalNumber)||o('"totalNumber" is incorrect. (Number)'):t.isFunction(e.totalNumberLocator)||o('"totalNumberLocator" should be a Function.'):i.isObject(e.dataSource)&&(void 0===e.locator?o('"dataSource" is an Object, please specify "locator".'):"string"==typeof e.locator||t.isFunction(e.locator)||o(e.locator+" is incorrect. (String | Function)")),void 0===e.formatResult||t.isFunction(e.formatResult)||o('"formatResult" should be a Function.')}function s(e){t.each(["go","previous","next","disable","enable","refresh","show","hide","destroy"],(function(t,a){e.off(r+a)})),e.data("pagination",{}),t(".paginationjs",e).remove()}t.each(["Object","Array","String"],(function(e,t){i["is"+t]=function(e){return function(e,t){return("object"==(t=typeof e)?null==e?"null":Object.prototype.toString.call(e).slice(8,-1):t).toLowerCase()}(e)===t.toLowerCase()}}))}(e,window.jQuery),function({debounce:e},t,a,r){Drupal.behaviors.searchApiJsLunr={attach:function(e,i){t(a("search-api-lunr-page",".search-api-lunr-page",e)).each((e,a)=>{const i=t(a),o=i.find(".search-api-js-page__input"),n=i.find(".search-api-js-page__form"),s=i.find(".search-api-js-page__results-container"),l=i.find(".search-api-js-page__results"),c=r.getIndexFromElement(a),u=v(window.location.search,{ignoreQueryPrefix:!0});function p(){c.search(o.val().trim()).then(e=>{s.pagination({dataSource:e,callback:(e,t)=>{let a;0===e.length?a=Drupal.theme("searchApiLunrNoResults"):(a=Drupal.theme("searchApiLunrResultSummary",t),a+=e.map(e=>Drupal.theme("searchApiLunrResult",e)).join("")),l.html(a)},className:"search-api-lunr-pager",ulClassName:"inline"})})}u.q&&(o.val(u.q),p()),n.on("submit",e=>{e.preventDefault(),p()})}),t(a("search-api-lunr-autocomplete",".search-api-lunr-autocomplete",e)).each((e,a)=>{const i=r.getIndexFromElement(a);t(a).autocomplete({delay:0,source:(e,t)=>{i.search(e.term,5).then(e=>{let a=e.map(e=>({label:e.getLabel(),value:e.getLabel(),matchedDocument:e}));t(a)})},select:(e,t)=>{window.location=t.item.matchedDocument.getUrl()}})})}}}(Drupal,jQuery,once,window.searchApiJs);
