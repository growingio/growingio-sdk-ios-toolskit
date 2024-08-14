var e,t,i=function(){return i=Object.assign||function(e){for(var t,i=1,n=arguments.length;n>i;i++)for(var r in t=arguments[i])({}).hasOwnProperty.call(t,r)&&(e[r]=t[r]);return e},i.apply(this,arguments)};function n(e,t,i){if(i||2===arguments.length)for(var n,r=0,o=t.length;o>r;r++)!n&&r in t||(n||(n=[].slice.call(t,0,r)),n[r]=t[r]);return e.concat(n||[].slice.call(t))}function r(e){return e&&e.__esModule&&{}.hasOwnProperty.call(e,"default")?e.default:e}"function"==typeof SuppressedError&&SuppressedError;var o,a,u,s,c,l="function"==typeof Array.from?Array.from:(t||(t=1,o=function(e){return"function"==typeof e},a=function(e){var t=function(e){var t=Number(e);return isNaN(t)?0:0!==t&&isFinite(t)?(t>0?1:-1)*Math.floor(Math.abs(t)):t}(e);return Math.min(Math.max(t,0),9007199254740991)},u=function(e){var t=e.next();return!t.done&&t},e=function(e){var t,i,n,r=this,s=arguments.length>1?arguments[1]:void 0;if(void 0!==s){if(!o(s))throw new TypeError("Array.from: when provided, the second argument must be a function");arguments.length>2&&(t=arguments[2])}var c=function(e,t){if(null!=e&&null!=t){var i=e[t];if(null==i)return;if(!o(i))throw new TypeError(i+" is not a function");return i}}(e,function(e){if(null!=e){if(["string","number","boolean","symbol"].indexOf(typeof e)>-1)return Symbol.iterator;if("undefined"!=typeof Symbol&&"iterator"in Symbol&&Symbol.iterator in e)return Symbol.iterator;if("@@iterator"in e)return"@@iterator"}}(e));if(void 0!==c){i=o(r)?Object(new r):[];var l,d,h=c.call(e);if(null==h)throw new TypeError("Array.from requires an array-like or iterable object");for(n=0;;){if(!(l=u(h)))return i.length=n,i;d=l.value,i[n]=s?s.call(t,d,n):d,n++}}else{var f=Object(e);if(null==e)throw new TypeError("Array.from requires an array-like object - not null or undefined");var g,v=a(f.length);for(i=o(r)?Object(new r(v)):Array(v),n=0;v>n;)g=f[n],i[n]=s?s.call(t,g,n):g,n++;i.length=v}return i}),e),d=function(e){try{return e()}catch(e){return}},h=function(e){return"number"===y(e)},f=function(e){return"object"===y(e)&&!function(e){return p(["undefined","null"],y(e))}(e)},g=function(e){return Array.isArray(e)&&"array"===y(e)},v=function(e,t){var i=-1;if(g(e))for(var n=0;n<e.length;n++)if(t(e[n]))return n;return i},p=function(e,t){return("array"===y(e)||"string"===y(e))&&e.indexOf(t)>=0},m=r(l),w=function(e){return g(e)?0===e.length:f(e)?0===function(e){return f(e)?Object.keys(e):[]}(e).length:!e},N=function(e){if(g(e)){for(var t=0,i=[],n=0,r=e;n<r.length;n++){var o=r[n];o&&!w(o)&&(i[t++]=o)}return i}return e},y=function(e){return{}.toString.call(e).slice(8,-1).toLowerCase()},b=["body","br","canvas","clippath","defs","desc","g","hr","html","iframe","math","param","path","rect","script","style","text","title","tspan","use"],L=["button","reset","submit"],E=n(n([],L,!0),["file"],!1),k=["checkbox","color","radio","range"],x=n(n([],k,!0),["date","datetime-local","month","number","password","text","time","week"],!1),T=["tr","li","dt","dd"],_=n(["a","button","dl"],T,!0),I=["i","em","svg","img"],C=["i","span","em","b","strong","bdo"],O=/(^| |[^ ]+\-)(clear|clearfix|active|hover|enabled|current|selected|unselected|hidden|display|focus|disabled|undisabled|open|checked|unchecked|undefined|null|ng-|growing-)[^\. ]*/g,S=/^([a-zA-Z\-\_0-9]+)$/,P="data-growing-ignore",B="data-growing-container",A="data-growing-index",D="data-growing-title",H=function(e,t){},G=function(e,t){var i;return null!==(i=d((function(){return e.hasAttribute(t)&&"false"!==e.getAttribute(t)})))&&void 0!==i?i:d((function(){return e.hasOwnPerporty(t)}))},X=function(e,t){var i;return null!==(i=d((function(){return e.getAttribute(t)})))&&void 0!==i?i:d((function(){return e.attributes[t].value}))},j=function(e){var t,i=!p(b,e.tagName.toLowerCase()),n=W(e);return i&&n&&p(C,null===(t=e.tagName)||void 0===t?void 0:t.toLowerCase())?j(n):e},M=function(e,t,i){if(void 0===t&&(t=5),void 0===i&&(i=0),!e.children)return!1;if("svg"===e.tagName.toLocaleLowerCase())return i>t;if(i>t)return!0;for(var n=0;n<e.children.length;n++){var r=e.children[n];if(M(r,t,i+1))return!0}return!1},J=function(e,t){var i=e.tagName.toLowerCase();if(!(e instanceof Element))return!1;if(G(e,P))return!1;if(p(b,i))return!1;if(p(["circleClick","circleHover","click"],t)){if("textarea"===i&&"click"===t)return!1;if("input"===i){if("click"===t&&!p(E,X(e,"type")))return!1;if(p(["circleClick","circleHover"],t)&&!p(n(n([],E,!0),x,!0),X(e,"type")))return!1}if(!Z(e)&&M(e,5))return!1}return!0},z=function(e,t){return void 0===t&&(t=!1),m((null==e?void 0:e.childNodes)||[]).filter((function(e){return p(t?[Node.ELEMENT_NODE,Node.TEXT_NODE]:[Node.ELEMENT_NODE],e.nodeType)}))},W=function(e){return F(e.parentElement)?null:e.parentElement},F=function(e){return!e||p(["BODY","HTML","#document"],e.tagName)},Z=function(e){return G(e,B)||p(_,e.tagName.toLowerCase())||"input"===e.tagName.toLowerCase()&&p(L,e.type)},R=function(e){var t=z(e);return!w(t)&&t.every((function(e){var t=Y(e),i=p(e.classList,"icon");return!(!t&&!i||U(e))}))},U=function(e){var t=z(e,!0);return!w(t)&&t.every((function(e){var t=e.nodeType===Node.TEXT_NODE,i=q(e);return!(!t||!i)}))},Y=function(e){return p(I,e.tagName.toLocaleLowerCase())},q=function(e){var t=z(e,!0).filter((function(e){var t;return e.nodeType===Node.TEXT_NODE||p(C,null===(t=e.tagName)||void 0===t?void 0:t.toLowerCase())})).map((function(e){return V(e.textContent,e.textContent.length)}));return V(N(t).join(" "))},V=function(e,t){return void 0===t&&(t=50),e&&(null==(e=e.replace(/[\n \t]+/g," ").trim())?void 0:e.length)?e.slice(0,h(t)&&t>0?t:void 0):""},$=/[^/]*.(bmp|jpg|jpeg|png|gif|svg|psd|webp|apng)/gi,K=function(e,t){switch(t){case"a":return function(e){if(G(e,"href")){var t=X(e,"href");if(t&&0!==t.indexOf("javascript"))return t.slice(0,320)}return""}(e);case"img":return function(e){var t=e.src;if(t&&-1===t.indexOf("data:image")){var i=t.match($),n=w(i)?"":i[0];if(n.indexOf("%")>-1){var r=function(e,t){var i=-1;if(g(e))for(var n=0;n<e.length;n++)"%"===e[n]&&(i=n);return i}(n.split(""));n=n.substring(r+3,n.length)}return n}return""}(e);default:return""}},Q={a:function(e){var t=q(e);return t||(ie(e)||K(e,"a"))},button:function(e){var t=X(e,"name");if(t)return t;var i=q(e);return i||(ie(e)||ne(e))},img:function(e){return V(X(e,"alt"))||K(e,"img")},input:function(e){if("password"===e.type)return"";var t,i,n=e instanceof HTMLInputElement&&p(E,e.type),r=G(e,"data-growing-track");if(n||r)return V(e.value);if(e instanceof HTMLInputElement&&p(k,e.type)){var o=void 0;if(e.id)i=function(t){return t.htmlFor===e.id},o=(t=m(document.getElementsByTagName("label")))[v(t,i)];return o||(o=te(e,(function(e){return"label"===e.tagName.toLowerCase()}))),re(e,o?q(o):V(e.value))}return""},label:function(e){var t=q(e);return t||(ie(e)||ne(e))},select:function(e){return V(m(e.options).filter((function(e){return e.selected})).map((function(e){return e.label})).join(", ")||e.value)},svg:function(e){var t;return z(e).some((function(e){var i;if(e.nodeType===Node.ELEMENT_NODE&&"use"===(null===(i=e.tagName)||void 0===i?void 0:i.toLowerCase())&&e.hasAttribute("xlink:href"))return t=e,!0})),t?t.getAttribute("xlink:href"):""},textarea:function(){return""},form:function(){return""}},ee=function(e,t){if(G(e,D)&&X(e,D))return V(X(e,D));if(G(e,"title")&&X(e,"title"))return V(X(e,"title"));var i=Q[t];if(i)return i(e);var n=q(e);return n?V(n):function(e){if("svg"===e.tagName)return!1;var t=z(e);return t.length>0&&t.every((function(e){return function(e){if("svg"===e.tagName)return!0;var t=z(e);if(w(t))return!0;var i=U(e);return!(!w(t)&&!i)}(e)}))}(e)&&!R(e)?V(ie(e)):R(e)?V(ne(e)):""},te=function(e,t){for(var i=e.parentElement;i&&!F(i);){if(t(i))return i;i=i.parentElement}},ie=function(e){var t=z(e);return N(t.map((function(e){var t=q(e);if(U(e)&&t)return t}))).join(" ")},ne=function(e){var t;return z(e).some((function(e){var i,n=ee(e,null===(i=e.tagName)||void 0===i?void 0:i.toLowerCase());return!!n&&(t=n,!0)})),t},re=function(e,t){return p(["checkbox","radio"],e.type)?"".concat(t).concat((i=e.checked,"boolean"===y(i)?"("+e.checked+")":"")):t;var i},oe=function e(t,i,r,o,a){var u=this;void 0===o&&(o=!0),void 0===a&&(a=[]),this.originNode=t,this.deviceInfo=i,this.actionType=r,this.trackable=o,this.parentNodes=a,this._getIndex=function(){if(G(u.originNode,A)){var e=X(u.originNode,A);return/^\d{1,10}$/.test(e)&&e-0>0&&2147483647>e-0?+e:void(0>u.actionType.indexOf("circle")&&H("".concat(e,"，index标记应为 大于 0 且小于 2147483647 的整数！"),"warn"))}if(p(["dd","dt"],u.tagName)){var t=W(u.originNode),i=t?z(t):[];if("dl"===t.tagName.toLowerCase()&&i.length>0){if("dd"===u.tagName){var r=v(i,(function(e){return e.isSameNode(u.originNode)}));if(r>-1)return(o=i.slice(0,r).filter((function(e){return"dt"===e.tagName.toLowerCase()}))).length-1+1}if("dt"===u.tagName){var o=i.filter((function(e){return"dt"===e.tagName.toLowerCase()}));return v(o,(function(e){return e.isSameNode(u.originNode)}))+1}}}if(u.isPureList){var a=v(u._pureList,(function(e){return e.isSameNode(u.originNode)}));return a>-1?(u.peerNodes=n([],u._pureList,!0),u.peerNodes.splice(a,1),a+1):void 0}if(u.isPseudoList){var s=v(u._pseudoList,(function(e){return e.isSameNode(u.originNode)}));return s>-1?(u.peerNodes=n([],u._pseudoList,!0),u.peerNodes.splice(s,1),s+1):void 0}},this._getSiblingNode=function(e,t){var i,n=W(e);if(!n)return[];for(var r=null!==(i=d((function(){return m(n.children)})))&&void 0!==i?i:[],o=[],a=0;a<r.length;a++){var u=r[a],s=r[a+1];if(!s||!t(u,s))break;w(o)?o.push(u,s):o.push(s)}return o},this._getIsPureList=function(){var e=u._getSiblingNode(u.originNode,(function(e,t){return e.tagName===t.tagName}));return!(1>e.length||!p(T,u.tagName)||(u._pureList=e,0))},this._getIsInPseudoList=function(){if(p(["th","td"],u.tagName))return!1;var e=u._getSiblingNode(u.originNode,(function(e,t){var i=e.tagName===t.tagName&&e.className===t.className,n=z(e),r=z(t),o=n.every((function(e,t){var i,n;return(null==e?void 0:e.tagName)===(null===(i=r[t])||void 0===i?void 0:i.tagName)&&(null==e?void 0:e.className)===(null===(n=r[t])||void 0===n?void 0:n.className)})),a=n.length===r.length&&o;return i&&a}));return e.length>=3&&(u._pseudoList=e,!0)},this._getClassList=function(e){var t;if(G(e,"name")&&X(e,"name"))return[X(e,"name")];var i=(null!==(t=X(e,"class"))&&void 0!==t?t:"").trim().split(" ");return w(i)?[]:i.filter((function(e){return e&&!O.test(e)&&S.test(e)})).sort()},this._getCurrentXpath=function(){return"/".concat(u.tagName).concat(u.id?"#"+u.id:"").concat(w(u.classList)?"":"."+u.classList.join("."))},this._getIsContainer=function(){return G(u.originNode,B)||p(_,u.tagName)||"input"===u.tagName&&p(L,u.originNode.type)},this._getContent=function(){u.content=ee(u.originNode,u.tagName)},this._getIsOutFlow=function(){var e=window.getComputedStyle(u.originNode).position;return p(["fixed","sticky"],e)},this._getRect=function(){var e=u.originNode.getBoundingClientRect(),t=e.top,i=e.bottom,n=e.left,r=e.right-n,o=i-t;return t+o>u.deviceInfo.winHeight&&(o=u.deviceInfo.winHeight-t),n+r>u.deviceInfo.winWidth&&(r=u.deviceInfo.winWidth-n),{top:t,left:n,width:r,height:o}},this._getViewStatus=function(){var e=window.getComputedStyle(u.originNode),t=e.opacity,i=e.visibility,n=e.display,r=e.width,o=e.height,a=u.rect,s=a.top,c=a.left,l=a.width,d=a.height,h=u.deviceInfo,f=h.winWidth,g=h.winHeight;if(0===Number(t)||"hidden"===i||"none"===n||"0px"===r||"0px"===o)return"HIDDEN";var v=function(e,t){return document.elementFromPoint(e,t)===u.originNode};return g>s&&f>c&&l>0&&d>0?v(c+l/2,s+d/2)||v(c+1,s+1)||v(c+l-1,s+1)||v(c+1,s+d-1)||v(c+l-1,s+d-1)?"DISPLAYED":0>s+d||0>c+l?"OUTSIDE":"OBSCURED":"OUTSIDE"},this._getTriggerEvent=function(){return"input"===u.tagName&&p(x,u.originNode.type)||p(["select","textarea"],u.tagName)?"VIEW_CHANGE":"VIEW_CLICK"},this._getXParents=function(t,i){var n=t.parentElement,r=[];if(i.length>0)r.push.apply(r,i);else for(;n&&!F(n);)r.push(new e(n,void 0,u.actionType,J(n,u.actionType))),n=n.parentElement;return r},this.tagName=t.tagName.toLocaleLowerCase(),this.classList=this._getClassList(t),this.id=t.id,this.currentXpath=this._getCurrentXpath(),this.isIgnored=G(this.originNode,P),this.isContainer=this._getIsContainer(),this.isPureList=this._getIsPureList(),this.isPseudoList=this._getIsInPseudoList(),this.index=this._getIndex(),this.hyperlink=K(t,this.tagName),this.content=ee(this.originNode,this.tagName),this.triggerEvent=this._getTriggerEvent(),this.isOutFlow=this._getIsOutFlow(),i&&(this.rect=this._getRect(),this.viewStatus=this._getViewStatus()),this.xParents=this._getXParents(t,a)},ae=function e(t,i,n,r,o){var a=this;this.origin=t,this.action=i,this.lengthThreshold=n,this.deviceInfo=r,this.parentNode=o,this.trackNodes=function(){var e;if(!a.trackable)return[];var t=[a.xNode];if(p(["click","circleClick","change"],a.actionType))for(var i=a._getParent();i;){if(!(null==i?void 0:i.xNode)||(null===(e=i.xNode)||void 0===e?void 0:e.isIgnored))return[];i.trackable&&t.push(i.xNode),i=i._getParent()}var n,r=[];return t.reverse().forEach((function(e,i){if(G(e.originNode,B)&&(r=[],n=void 0),h(e.index)&&!h(n)&&(n=e.index),h(n)&&(e.index=n),i===t.length-1)r.push(a.getGioNodeInfo(e));else{var o=e.isPureList||e.isPseudoList;(e.isContainer||o)&&r.push(a.getGioNodeInfo(e))}})),r},this.getGioNodeInfo=function(e){var t=a.computeXpath(e),i=t.skeleton,n=t.fullXpath,r=t.xpath,o=t.xcontent,u=e.hyperlink,s=e.index,c=e.peerNodes,l=e.content,d=e.triggerEvent,h=e.originNode;return{skeleton:i,fullXpath:n,xpath:r,xcontent:o,hyperlink:u,index:s,peerNodes:null!=c?c:[],content:V(l),triggerEvent:d,originNode:h}},this.computeXpath=function(e){var t,i="/"+e.tagName,n=e.currentXpath,r=e.currentXpath,o="/"+((e.id?"#"+e.id:"")+(w(e.classList)?"":"."+e.classList.join("."))||"-");return null===(t=e.xParents)||void 0===t||t.forEach((function(e,t){if(n=e.currentXpath+n,t<a.xpathThreshold-1){i="/"+e.tagName+i,r=e.currentXpath+r;var u=(e.id?"#"+e.id:"")+(w(e.classList)?"":"."+e.classList.join("."));o="/"+(u||"-")+o}})),{skeleton:i,fullXpath:n,xpath:r,xcontent:o}},this._getParent=function(){var t=W(a.originElement);if(t&&t.nodeName&&!F(t))return new e(t,a.actionType)},this.actionType=p(["circleClick","circleHover","click","change"],i)?i:"click",this.originElement=j(t),this.xpathThreshold=h(n)?n:4,this.trackable=J(this.originElement,this.actionType);var u=[];o&&o.xNode&&(u.push(o.xNode),o.xNode.xParents&&u.push.apply(u,o.xNode.xParents)),this.xNode=new oe(this.originElement,this.deviceInfo,this.actionType,this.trackable,u)},ue=[],se=function(e,t){var n,r,o,a,u,s,c,l=this;this.trackNodes=function(e,t){return ue=[],l._getTrackElements(e,t,null),ue},this._getTrackElements=function(e,t,i){z(e).forEach((function(e){var n,r,o,a,u;if(!(null==e?void 0:e.tagName)||"circle-shape"===(null===(n=null==e?void 0:e.tagName)||void 0===n?void 0:n.toLowerCase())||"heatmap-page"===(null===(r=null==e?void 0:e.tagName)||void 0===r?void 0:r.toLowerCase())||(null===(o=null==e?void 0:e.id)||void 0===o?void 0:o.indexOf("__vconsole"))>-1||(null===(a=null==e?void 0:e.id)||void 0===a?void 0:a.indexOf("__giokit"))>-1)return!1;var s=new ae(e,"circleClick",l.xpathThreshold,l.deviceInfo,i),c=s.xNode;if(c.zLevel=l._getZLevel(e,t),s.trackable&&p(["DISPLAYED","OBSCURED"],c.viewStatus)){if(t.index&&(c.index=t.index),"DISPLAYED"===c.viewStatus){var d=l._getGioHybridNodeInfo(s,t);ue.push(d)}else"OBSCURED"===c.viewStatus&&c.isContainer&&(d=l._getGioHybridNodeInfo(s,t),ue.push(d));if(Y(e)||c.isContainer&&U(e))return!1}w(z(e))||l._getTrackElements(e,null!==(u=s.xNode)&&void 0!==u?u:t,s)}))},this._getZLevel=function(e,t){var i=window.getComputedStyle(e),n=i.position,r=i.zIndex;if("auto"!==r){var o=Number(r||0);return(Number.isNaN(o)?0:o)+t.zLevel}switch(n){case"relative":return t.zLevel+2;case"sticky":return t.zLevel+3;case"absolute":return t.zLevel+4;case"fixed":return t.zLevel+5;default:return t.zLevel+1}},this._getGioHybridNodeInfo=function(e,t){var n=e.xNode,r=n.rect,o=n.zLevel,a=e.getGioNodeInfo(n),u=a.hyperlink;return i(i(i({},r),a),{zLevel:o+l.deviceInfo.webviewZLevel,href:u,parentXPath:t.trackable?e.computeXpath(t).xpath:void 0})},this.xpathThreshold=t,this.deviceInfo=(r=(n=e).webviewLeft,o=n.webviewTop,a=n.webviewWidth,u=n.webviewHeight,s=n.webviewZLevel,{winWidth:c=document.documentElement.clientWidth,winHeight:document.documentElement.clientHeight,scale:a/c,webviewTop:o,webviewLeft:r,webviewWidth:a,webviewHeight:u,webviewZLevel:s})},ce=function(){function e(){this.elements=[],this.scale=1,window.GiokitTouchJavascriptBridge?this.hasTouchBridge=!0:this.hasTouchBridge=!1,this.initGiokitTouchJavascriptBridge()}return e.prototype.initGiokitTouchJavascriptBridge=function(){var e=this;window.GiokitTouchJavascriptBridge&&(window.GiokitTouchJavascriptBridge.hoverOn=function(t,i,n){1===e.scale&&(e.scale=window.innerWidth/t),e.hoverOn(i*e.scale,n*e.scale)},window.GiokitTouchJavascriptBridge.highLightElementAtPoint=function(){var t,i;e.elements=[],e.highLightElements([e.lastElement]),(null===(i=null===(t=window.webkit)||void 0===t?void 0:t.messageHandlers)||void 0===i?void 0:i.GiokitTouchJavascriptBridge.postMessage)?window.webkit.messageHandlers.GiokitTouchJavascriptBridge.postMessage(JSON.stringify(e.lastElement)):window.GiokitTouchJavascriptBridge.hoverNodes(JSON.stringify(e.lastElement))},window.GiokitTouchJavascriptBridge.cancelHover=function(){e.elements=[],e.hideMask()},this.hasTouchBridge=!0)},e.prototype.getDeviceInfo=function(){return{webviewLeft:0,webviewTop:0,webviewWidth:document.body.clientWidth,webviewHeight:document.body.clientHeight,webviewZLevel:0}},e.prototype.getAllNodes=function(){var e=new se(this.getDeviceInfo()),t=(new Date).getTime();this.elements=e.trackNodes(document.body,{isContainer:!1,zLevel:0});var i=(new Date).getTime();H("getAllNodes cost "+(i-t),"info")},e.prototype.highLightElements=function(e){document.body.querySelectorAll(".giokit_mask").forEach((function(e){e.remove()})),e.forEach((function(e){var t=document.createElement("div");t.setAttribute("data-growing-ignore",""),t.className="giokit_mask",t.style.backgroundColor="rgba(252,95,58,0.1)",t.style.border="1px solid red";var i=e.top+window.scrollY,n=e.left+window.scrollX;t.style.zIndex="9999",t.style.left=n+"px",t.style.top=i+"px",t.style.width=e.width+"px",t.style.height=e.height+"px",t.style.position="absolute",t.style.pointerEvents="none",document.body.appendChild(t)}))},e.prototype.hoverOn=function(e,t){if(this.hasTouchBridge||(H("GiokitTouchJavascriptBridge is not exist!","info"),this.initGiokitTouchJavascriptBridge()),this.hasTouchBridge){0===this.elements.length&&this.getAllNodes();var i=this.elements.filter((function(i){return!(i.left>e||i.width+i.left<e||i.top>t||i.top+i.height<t)}));0!=i.length?(this.highLightElements(i),this.lastElement=i.sort((function(e,t){return e.width*e.height-t.width*t.height}))[0]):this.hideMask()}},e.prototype.hideMask=function(){document.body.querySelectorAll(".giokit_mask").forEach((function(e){e.remove()})),this.lastElement=null},e}(),le="giokitTouch";(null===(c=window[le])||void 0===c?void 0:c.giokitTouchInstalled)?(s=window[le],H("重复加载!","warn")):(H("GiokitTouch init","info"),s=new ce,window[le]=s,window.giokitTouch=s,window.giokitTouchInstalled=!0);
