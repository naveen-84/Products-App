String reverse(String str) {
  if (str.isEmpty) return "";
  return reverse(str.substring(1)) + str[0];
}

void main() {
  print(reverse("hello"));
}
