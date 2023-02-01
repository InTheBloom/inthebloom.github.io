/* 参考
 * https://www.webcreatorbox.com/tech/intersection-observer
 * https://qiita.com/tomcky/items/07190a3a2d0d993d1b56
 * https://www.ipentec.com/document/javascript-template-literal-string-using-tag
 * https://ics.media/entry/190902/
 * https://www.mitsue.co.jp/knowledge/blog/frontend/201803/28_1056.html
*/

document.addEventListener('DOMContentLoaded', function() {
	const heads = document.querySelectorAll("h2, h3, h4, h5, h6");

	const options = {
		root: null,
		rootMargin: '0% 0px -70% 0px',
		threshold: 0
	}

	const observer = new IntersectionObserver(callback, options);

	heads.forEach(head => {
		observer.observe(head);
	});

	function callback(entries) {
		entries.forEach(entry => {
			if (entry.isIntersecting) {
				activateIndex(entry.target);
			}
		});
	};

	let filename = '';
	let tmp = window.location.href.split('/');
	for (; filename.indexOf('html') == -1; filename = tmp.pop()) {}

	function activateIndex(element) {
		const current = document.querySelector(".active");
		if (current !== null) {
			current.classList.remove("active");
		}
		const a = document.querySelector(`a[href='articles/${filename}#${element.id}']`);
		a.classList.add("active");
	}
});
