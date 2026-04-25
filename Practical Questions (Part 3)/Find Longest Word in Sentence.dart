String longestWord(String sentence) {
  List<String> words = sentence.split(" ");
  String longest = "";

  for (String word in words) {
    if (word.length > longest.length) {
      longest = word;
    }
  }
  return longest;
}

void main() {
  print(longestWord("Flutter is very powerful framework"));
}
