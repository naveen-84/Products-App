class Solution {
  int lengthOfLongestSubstring(String s) {
    Set<String> set = {};
    int left = 0, maxLength = 0;

    for (int right = 0; right < s.length; right++) {
      while (set.contains(s[right])) {
        set.remove(s[left]);
        left++;
      }
      set.add(s[right]);
      maxLength = maxLength > (right - left + 1)
          ? maxLength
          : (right - left + 1);
    }
    return maxLength;
  }
}
