import 'package:flutter/material.dart';

int page = 1;
bool isLoading = false;
List data = [];
ScrollController _controller = ScrollController();

@override
void initState() {
  super.initState();
  fetchData();
  _controller.addListener(() {
    if (_controller.position.pixels == _controller.position.maxScrollExtent) {
      fetchData();
    }
  });
}

Future<void> fetchData() async {
  if (isLoading) return;

  setState(() => isLoading = true);

  final response = await http.get(
    Uri.parse(
      "https://jsonplaceholder.typicode.com/posts?_page=$page&_limit=10",
    ),
  );

  if (response.statusCode == 200) {
    List newData = json.decode(response.body);
    setState(() {
      page++;
      data.addAll(newData);
      isLoading = false;
    });
  }
}
