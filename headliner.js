document.addEventListener('DOMContentLoaded', () => {
	const heads = document.querySelectorAll('h2, h3, h4, h5, h6');
	if (heads && heads.length) {
		let contents = '';
		let filename = '';
		let tmp = window.location.href.split('/');
		for (; filename.indexOf('html') == -1; filename = tmp.pop()) {}
		heads.forEach((head, i) => {
			let className = '';
			head.setAttribute('id', "head" + i);
			switch(head.localName) {
				case "h2":
					className = `contents2`;
					break;
				case "h3":
					className = `contents3`;
					break;
				case "h4":
					className = `contents4`;
					break;
				case "h5":
					className = `contents5`;
					break;
				case "h6":
					className = `contents6`;
					break;
			}
			contents += `<li><a class="${className}" href="articles/${filename}/#head${i}">${head.textContent}</a></li>`;
		})
		document.querySelector('#table-of-content').innerHTML += `<p>目次</p>`;
		document.querySelector('#table-of-content').innerHTML += `<ol>${contents}</ol>`;
	}
});
