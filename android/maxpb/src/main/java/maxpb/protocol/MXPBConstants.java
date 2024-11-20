package maxpb.protocol;

public class MXPBConstants {

    public static final short DEFAULT_VALUE = 0x0000;
    public static final String FP_SOF_DEFAULT_VALUE = "AA55AA55";
    public static final short MT_CMD_POSITION = 0x0001;
    public static final short MT_ACK = 0x0002;
    public static final short MT_NACK = 0x0003;
    public static final short MT_ROUTE_PACK = 0x0004;
    public static final short MT_CMD_FILE_CHANGE = 0x0006;
    public static final short MT_CMD_FILE_REQUEST_DATA = 0x0007;
    public static final short MT_CMD_FILE_DATA = 0x0008;
    public static final short MT_CMD_CONFIG = 0x0010;
    public static final short MT_CMD_STATUS = 0x0011;
    public static final short MAXPB_CMD_MULTIPLE_REPORT_LORA = 0x0012;
    public static final short MT_CMD_PASSWORD = 0x0021;
    public static final short MT_CMD_PASSWORD_STORE = 0x0022;
    public static final short MT_CMD_PASSWORD_MASTER = 0x0105;
    public static final short MT_CMD_TRACE_CONFIG = 0x0102;
    public static final short MT_CMD_POS_CONNECT = 0x0106;
    public static final short MT_KEEP_ALIVE = 0x0000;
    public static final short MAXPB_CMD_FILE_CANCEL = 0x000A;

    public static final String KEEP_ALIVE_DATA = "55AA55AA0600000000000000";

    public static final short SOF_SIZE = 4;
    public static final short SIZE_SIZE = 2;
    public static final short CRC_SIZE = 2;
    public static final short MT_SIZE = 2;
    public static final short PF_SIZE = 2;

    public static final String REQUEST_STATUS_WAITING_POSITION = "request_status_position";
    public static final String REQUEST_STATUS_WAITING_POSITION_CONN = "request_status_position_conn";
    public static final String REQUEST_STATUS_WAITING_PASSWORD = "request_status_password";
    public static final String REQUEST_STATUS_RECEIVED = "ok";
    public static final String REQUEST_STATUS_POSITION_FAILED = "position_failed";
    public static final String REQUEST_STATUS_INVALID_PASSWORD = "invalid_password";
    public static final String REQUEST_STATUS_LOCKED_PASSWORD = "locked_password";
    public static final String REQUEST_STATUS_LOCKED_SESSION = "locked_session";

    public static final int NACK_CODE_INVALID_PASSWORD = 7;
    public static final int NACK_CODE_LOCKED = 10;

}
