// nanoid@3.3.18 downloaded from https://ga.jspm.io/npm:nanoid@3.3.18/index.browser.js

export{urlAlphabet}from"./url-alphabet/index.js";let e=e=>crypto.getRandomValues(new Uint8Array(e)),t=(e,t,n)=>{let r=(2<<Math.log(e.length-1)/Math.LN2)-1,i=-~(1.6*r*t/e.length);return(a=t)=>{if(a<=0)return``;let o=``;for(;;){let t=n(i),s=i|0;for(;s--;)if(o+=e[t[s]&r]||``,o.length===a)return o}}},n=(n,r=21)=>t(n,r,e),r=(e=21)=>crypto.getRandomValues(new Uint8Array(e)).reduce((e,t)=>(t&=63,t<36?e+=t.toString(36):t<62?e+=(t-26).toString(36).toUpperCase():t>62?e+=`-`:e+=`_`,e),``);export{n as customAlphabet,t as customRandom,r as nanoid,e as random};

