/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package util;

import java.io.FileInputStream;
import java.io.FileOutputStream;

/**
 *
 * @author santi
 */
public class ExtractAYFXAFB {
    public static void main(String args[]) throws Exception
    {
//        String afbFileName = "data/sfx/WESTEN_OFFICIAL_sfx.afb";
//        String afbFileName = "data/sfx/WESTEN_OFFICIAL_sfx_LESS_VOL.afb";
//        String afbFileName = "data/sfx/WESTEN_OFFICIAL_sfx_V2.afb";
//        boolean hasName = true;
        String afbFileName = "data/sfx/WESTEN_OFFICIAL_sfx_V3_NO_NAMES.afb";
        boolean hasName = false;
        
        FileInputStream fis = new FileInputStream(afbFileName);
        byte data[] = fis.readAllBytes();
        
        int nEffects = data[0] & 0xff;
        System.out.println("nEffects: " + nEffects);
        
        for(int i = 0;i<nEffects;i++) {
            int offset = 2 + i*2 + (data[1+i*2] & 0xff) + (data[2+i*2] & 0xff)*256;
            extractEffect(offset, data, "data/sfx/sfx" + i + ".afx", hasName);
        }
    }

    
    private static void extractEffect(int offset, byte[] data, String file, boolean hasName) throws Exception {
        FileOutputStream fos = new FileOutputStream(file);
        for(;;offset++) {
            fos.write(data[offset] & 0xff);
            if ((data[offset-1] & 0xff) == 0xd0 && (data[offset] & 0xff) == 0x20) {
                break;
            }
        }
        fos.flush();
        fos.close();
        
        if (hasName) {
            String name = "";
            for(;data[offset] != 0;offset++) {
                name += (char)data[offset];
            }
            System.out.println(file + "  ->  " + name);
        }
        
    }
}
