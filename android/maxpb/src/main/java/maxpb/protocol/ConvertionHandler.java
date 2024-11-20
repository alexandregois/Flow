package maxpb.protocol;

import org.apache.commons.lang3.ArrayUtils;

import java.math.BigInteger;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;

public class ConvertionHandler {

    public static int byteArrayToInt(byte[] byteArray) {

        StringBuffer buf = new StringBuffer();
        ArrayUtils.reverse(byteArray);

        for (int i = 0; i < byteArray.length; i++) {

            int halfbyte = (byteArray[i] >>> 4) & 0x0F;
            int two_halfs = 0;

            do {
                if ((0 <= halfbyte) && (halfbyte <= 9)) {
                    buf.append((char) ('0' + halfbyte));
                } else {
                    buf.append((char) ('a' + (halfbyte - 10)));
                }
                halfbyte = byteArray[i] & 0x0F;

            } while (two_halfs++ < 1);
        }

        return Integer.parseInt(buf.toString(), 16);
    }

    public static byte[] intToByteArray(int value) {

        ByteBuffer buffer = ByteBuffer.allocate(4);
        buffer.order(ByteOrder.BIG_ENDIAN);
        byte[] bytes = buffer.putInt(value).array();
        ArrayUtils.reverse(bytes);
        return bytes;
    }

    public static byte[] shortToByteArray(short value) {

        ByteBuffer buffer = ByteBuffer.allocate(2);
        buffer.order(ByteOrder.BIG_ENDIAN);
        byte[] bytes = buffer.putShort(value).array();
        ArrayUtils.reverse(bytes);
        return bytes;
    }

    public static byte[] bigIntToByteArray(BigInteger value) {

        ByteBuffer buffer = ByteBuffer.allocate(4);
        buffer.order(ByteOrder.BIG_ENDIAN);
        byte[] bytes = buffer.putInt(value.intValue()).array();
        ArrayUtils.reverse(bytes);
        return bytes;
    }

    public static short crc16ccitt(byte[] content) {

        short crc = 0;          // initial value
        int polynomial = 0x1021;   // 0001 0000 0010 0001  (0, 5, 12)

        for (byte b : content) {
            for (int i = 0; i < 8; i++) {
                boolean bit = ((b >> (7 - i) & 1) == 1);
                boolean c15 = ((crc >> 15 & 1) == 1);
                crc <<= 1;
                if (c15 ^ bit) {
                    crc ^= polynomial;
                }
            }
        }

        //crc &= 0x0000;
        return crc;
    }

    public static int crc32(byte[] content) {

        int crc = 0xFFFFFFFF;       // initial contents of LFBSR
        int poly = 0xEDB88320;   // reverse polynomial

        for (byte b : content) {
            int temp = (crc ^ b) & 0xff;
            for (int i = 0; i < 8; i++) {
                if ((temp & 1) == 1) {
                    temp = (temp >>> 1) ^ poly;
                } else {
                    temp = (temp >>> 1);
                }
            }

            crc = (crc >>> 8) ^ temp;
        }

        crc ^= 0xFFFFFFFF;
        return crc;
    }

    public static byte[] hexStringToByteArray(String s) {
        int len = s.length();
        byte[] data = new byte[len / 2];
        for (int i = 0; i < len; i += 2) {
            data[i / 2] = (byte) ((Character.digit(s.charAt(i), 16) << 4)
                    + Character.digit(s.charAt(i + 1), 16));
        }
        return data;
    }

    final protected static char[] hexArray = "0123456789ABCDEF".toCharArray();

    public static String byteArrayToHexString(byte[] bytes) {
        char[] hexChars = new char[bytes.length * 2];
        for (int j = 0; j < bytes.length; j++) {
            int v = bytes[j] & 0xFF;
            hexChars[j * 2] = hexArray[v >>> 4];
            hexChars[j * 2 + 1] = hexArray[v & 0x0F];
        }
        return new String(hexChars);
    }
}
