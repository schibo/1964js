library stringutils;

class StringUtils {

  /**
   * Returns a hexadecimal representaion of an integer.
   * Convenient for printing in log messages.
   */
  static String dec2hex(int u) {
    int d = 0;
    String hD = "0123456789ABCDEF";
    d = u;
    String h = hD.substring((d & 15), (d & 15) + 1);
    for (;;) {
      d >>= 4;
      d &= 0x0fffffff;
      h = hD.substring((d & 15), (d & 15) + 1).concat(h);
      if (!(d > 15)) {
        break;
      }
    }
    return h;
  }
}
