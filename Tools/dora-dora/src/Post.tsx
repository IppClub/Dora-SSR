async function Post(url: string, data: any = {}) {
	if (!process.env.NODE_ENV || process.env.NODE_ENV === 'development') {
		url = "http://localhost:8866" + url;
	}
	const response = await fetch(url, {
		method: 'POST',
		headers: {
			'Content-Type': 'application/json',
		},
		body: JSON.stringify(data)
	});
	return response.json();
};

export default Post;
