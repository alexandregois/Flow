package maxpb.protocol;

import org.apache.commons.lang3.ArrayUtils;

import java.math.BigInteger;
import java.util.Arrays;

import static maxpb.protocol.MXPBConstants.CRC_SIZE;
import static maxpb.protocol.MXPBConstants.DEFAULT_VALUE;
import static maxpb.protocol.MXPBConstants.FP_SOF_DEFAULT_VALUE;
import static maxpb.protocol.MXPBConstants.MT_SIZE;
import static maxpb.protocol.MXPBConstants.PF_SIZE;
import static maxpb.protocol.MXPBConstants.SIZE_SIZE;
import static maxpb.protocol.MXPBConstants.SOF_SIZE;

public class MaxPBProtocol {

    // bytes  description
    private byte[] fpSOF;     // [4]    Start of Frame - frame position SOF - Define inicio da mensagem [4]
    private byte[] fpSIZE;    // [2]    Tamanho do pacote - [2] - Define numero de bytes existentes a partir do campo “CRC” (CRC, MT, PF, INF and DATA)
    private byte[] fpCRC;     // [2]    CRC16-CCITT (Start value = 0x0000) - Calculo de CRC a partir do campo “MT” até o ultimo byte do campo “DATA”.
    private byte[] fpMT;      // [2]    Message type - Define o tipo de mensagem enviada, para lista completa de tipos de mensagens disponíveis.
    private byte[] fpPF;      // [2]    Packet Format - Define o tipo de informação presente no campo “INF”. Quando nenhuma informação presente no campo “INF”, “PF” é igual a zero (0x0000)
    //private byte[] fpINF;   // [N]    Information - Campo previsto para envio de informações adicionais, como exemplo IMEI, tipo de criptografia e outros. O tipo de informação enviada é definida no campo “PF”. Quando nenhuma informação adicional (PF = 0x0000), o campo INF ??????????????i.
    private byte[] fpDATA;    // [M]    DATA – ReportedData -   Envio de informações reportado pelo equipamento, de tamanho variável de acordo com o tipo de mensagem enviada, tipo de mensagem definida pelo campo “MT”. O formato de dados enviados nesse campo é codificado pelo Protocol Buffers 2.
    private byte[] body;      // [12+N+M]
    private short fpMTValue;
    private String fpSOFValue;
    private int fpDATALength;
    private int sizeValue;

    public MaxPBProtocol(short messageType, byte[] data) {

        encodeMessage(messageType, data);
    }

    public MaxPBProtocol(byte[] byteArray) {

        this.body = byteArray;
        decodeMessage();
    }

    private void decodeMessage() {

        fpSOF = Arrays.copyOfRange(body, 0, 4);
        fpSIZE = Arrays.copyOfRange(body, 4, 6);
        fpCRC = Arrays.copyOfRange(body, 6, 8);
        fpMT = Arrays.copyOfRange(body, 8, 10);
        fpPF = Arrays.copyOfRange(body, 10, 12);

        ArrayUtils.reverse(fpSOF);
        fpSOFValue = ConvertionHandler.byteArrayToHexString(fpSOF);

        if (fpSOFValue.equals(FP_SOF_DEFAULT_VALUE)) {

            int fpSizeValue = ConvertionHandler.byteArrayToInt(fpSIZE);
            sizeValue = fpSizeValue;
            fpMTValue = (short) ConvertionHandler.byteArrayToInt(fpMT);
            fpDATALength = (fpSizeValue - CRC_SIZE - MT_SIZE - PF_SIZE);
            fpDATA = Arrays.copyOfRange(body, 12, fpDATALength + 12);
        }
    }

    private void encodeMessage(short messageType, byte[] data) {

        fpSOF = new byte[SOF_SIZE];
        fpSIZE = new byte[SIZE_SIZE];
        fpCRC = new byte[CRC_SIZE];
        fpMT = new byte[MT_SIZE];
        fpPF = new byte[PF_SIZE];

        fpMT = ConvertionHandler.shortToByteArray(messageType);
        fpDATA = data;
        fpSOF = ConvertionHandler.bigIntToByteArray(new BigInteger(FP_SOF_DEFAULT_VALUE, 16));

        short sizeSize = (short) (CRC_SIZE + MT_SIZE + PF_SIZE + fpDATA.length);
        fpSIZE = ConvertionHandler.shortToByteArray(sizeSize);

        short fpSize = DEFAULT_VALUE;
        fpPF = ConvertionHandler.shortToByteArray(fpSize);

        byte[] contentToCRC16 = new byte[MT_SIZE + PF_SIZE + fpDATA.length];
        int pos = 0;
        System.arraycopy(fpMT, 0, contentToCRC16, pos, MT_SIZE);
        pos += MT_SIZE;
        System.arraycopy(fpPF, 0, contentToCRC16, pos, PF_SIZE);
        pos += PF_SIZE;
        System.arraycopy(fpDATA, 0, contentToCRC16, pos, fpDATA.length);

        fpCRC = ConvertionHandler.shortToByteArray(ConvertionHandler.crc16ccitt(contentToCRC16));

        buildBody();
    }

    public void buildBody() {

        this.body = new byte[fpSOF.length + SIZE_SIZE + CRC_SIZE + MT_SIZE + PF_SIZE + fpDATA.length];

        int pos = 0;
        System.arraycopy(fpSOF, 0, body, 0, SOF_SIZE);
        pos += SOF_SIZE;
        System.arraycopy(fpSIZE, 0, body, pos, SIZE_SIZE);
        pos += SIZE_SIZE;
        System.arraycopy(fpCRC, 0, body, pos, CRC_SIZE);
        pos += CRC_SIZE;
        System.arraycopy(fpMT, 0, body, pos, MT_SIZE);
        pos += MT_SIZE;
        System.arraycopy(fpPF, 0, body, pos, PF_SIZE);
        pos += PF_SIZE;
        System.arraycopy(fpDATA, 0, body, pos, fpDATA.length);
    }

    public byte[] getBody() {
        return body;
    }

    public short getFpMTValue() {
        return fpMTValue;
    }

    public byte[] getFpDATA() {
        return fpDATA;
    }

    public String getFpSOFValue() {
        return fpSOFValue;
    }

    public int getTotalSize() {
        return sizeValue + SOF_SIZE + SIZE_SIZE;
    }

}
