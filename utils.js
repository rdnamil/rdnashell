function parseJsonFromFile(path) {
	var xhr = new XMLHttpRequest();
	xhr.open("GET", path, false); // Synchronous
	xhr.send();
	return JSON.parse(xhr.responseText);
}
