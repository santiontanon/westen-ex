package westen;

import PNGtoMSX.ConvertPatternsToAssembler;
import java.awt.image.BufferedImage;
import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import javax.imageio.ImageIO;
import util.Pair;
import util.Z80Assembler;
import util.ZX0Wrapper;

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */

/**
 *
 * @author santi
 */
public class TravelCutscene {
    public static int TOLERANCE = 32;

    public static void main(String args[]) throws Exception
    {
        String gfxFilePath = "data/travel-map.png";
        
        ConvertPatternsToAssembler.MSX1Palette = Walls.MSX1Palette;
        BufferedImage img = ImageIO.read(new File(gfxFilePath));
        
        // List of pixels that are different between start/end states of the map
        List<int[]> differences = new ArrayList<>();
        
        for(int j = 0;j<22*8;j++) {
            for(int i = 0;i<10*8;i++) {
                int color1 = ConvertPatternsToAssembler.findMSXColor(j+5*8, i, img, TOLERANCE);
                int color2 = ConvertPatternsToAssembler.findMSXColor(j+5*8, i+11*8, img, TOLERANCE);
                if (color1 != color2) {
                    differences.add(new int[]{j, i});
                }
            }
        }
        System.out.println("different pixels: " + differences.size());
        
        
        int nameTable[][] = new int[22][10];
        List<List<Integer>> tiles = new ArrayList<>();
        
        List<Integer> data = new ArrayList<>();
        int tilesDataOffset = 0;
        int spritesAttributeOffset = 0;
        int spritesDataOffset = 0;
        
        // Try to represent the image with tiles, but if not possible, use
        // sprites to represent the red parts:
        for(int i = 0;i<10;i++) {
            for(int j = 0;j<22;j++) {
                int name = getTileIfPossible(j+5, i+11, img, tiles);
                nameTable[j][i] = name;
            }
        }

        System.out.println("tiles: " + tiles.size());
        for(int i = 0;i<10;i++) {
            for(int j = 0;j<22;j++) {
                System.out.print(nameTable[j][i] + "\t");
                data.add(nameTable[j][i]+1);
            }
            System.out.println("");
        }
        
        data.add((tiles.size()*8) % 256);
        data.add((tiles.size()*8) / 256);
        tilesDataOffset = data.size();
        // patterns:
        for(List<Integer> tile:tiles) {
            for(int i = 0;i<8;i++) data.add(tile.get(i*2));
        }
        // attributes:
        for(List<Integer> tile:tiles) {
            for(int i = 0;i<8;i++) data.add(tile.get(i*2+1));
        }
        
        // Capture the rest using sprites:
        List<Integer> spritesAttributeData = new ArrayList<>();
        List<Integer> spritesData = new ArrayList<>();
        int nsprites = 0;
        for(int i = 12;i<20;i+=2) {
            for(int j = 5;j<27;j+=2) {
                List<Integer> spriteData = new ArrayList<>();
                boolean anyPixel = false;
                for(int xx = 0;xx<2;xx++) {
                    for(int y = 0;y<16;y++) {
                        int row = 0;
                        for(int x = 0;x<8;x++) {
                            int color = ConvertPatternsToAssembler.findMSXColor((j+xx)*8+x, i*8+y, img, TOLERANCE);
                            row *= 2;
                            if (color > 0) {
                                anyPixel = true;
                                row += 1;
                            }
                        }
                        spriteData.add(row);
                    }
                }
                if (anyPixel) {
                    spritesAttributeData.add((i-6)*8-1);
                    spritesAttributeData.add(j*8);
                    spritesAttributeData.add((60+nsprites)*4);
                    spritesAttributeData.add(8);  // color red
                    spritesData.addAll(spriteData);
                    System.out.println((j*8) + ", " + ((i-6)*8-1));
                    System.out.println(spriteData);
                    nsprites++;
                }
            }
        }        
        spritesAttributeOffset = data.size();
        data.addAll(spritesAttributeData);
        spritesDataOffset = data.size();
        data.addAll(spritesData);
        System.out.println("sprites: " + nsprites);
        
        List<Pair<Integer, Integer>> changes = new ArrayList<>();
        // Calculate the sequence of bytes needed to show the animation:
        for(int i = differences.size()-1;i>=0;i--) {
            int pixel[] = differences.get(i);
            int color2 = ConvertPatternsToAssembler.findMSXColor(pixel[0]+5*8, pixel[1]+11*8, img, TOLERANCE);
            if (color2 > 0) {
                // sprite:
                System.out.println(i + ": sprite");
                for(int j = 0;j<nsprites;j++) {
                    int spritey = data.get(spritesAttributeOffset + j*4) + 1 - 5*8;
                    int spritex = data.get(spritesAttributeOffset + j*4 + 1) - 5*8;
//                    System.out.println("spritex,spritey: " + spritex+ "," + spritey);
//                    System.out.println("pixel: " + pixel[0]+ "," + pixel[1]);
                    if (pixel[0] >= spritex && pixel[0] < spritex + 16 &&
                        pixel[1] >= spritey && pixel[1] < spritey + 16) {
                        // sprite found:
                        int spriteoffset = pixel[1] - spritey;
                        int px = pixel[0] - spritex;
                        if (px >= 8 ) {
                            spriteoffset += 16;
                            px -= 8;
                        }
                        int mask = 0x01;
                        for(int k = 7;k>px;k--) {
                            mask*=2;
                        }
                        mask = mask ^ 0xff;
                        int offset = spritesDataOffset + j*32 + spriteoffset;
                        int vdppointer = 0x3800 + (j+60)*32 + spriteoffset;
                        int oldValue = data.get(offset);
                        int newValue = oldValue & mask;
                        data.set(offset, newValue);
                        changes.add(0, new Pair<>(vdppointer, oldValue));
//                        System.out.println("sprite: " + j + "\tpx,py: " + (pixel[0] - spritex) + "," + (pixel[1] - spritey) + "\tmask: " + mask + "\tvalue: " + oldValue + " -> " + newValue);
                        break;
                    }
                }
            } else {
                // tile:
                System.out.println(i + ": tile");
                int tx = pixel[0]/8;
                int ty = pixel[1]/8;
                int px = pixel[0] - tx*8;
                int py = pixel[1] - ty*8;
                int name = nameTable[tx][ty];
                int mask = 0x01;
                for(int j = 7;j>px;j--) {
                    mask*=2;
                }
                int offset = tilesDataOffset + name*8 + py;
                int vdppointer = 0x0000 + (name+1)*8 + py;
                int oldValue = data.get(offset);
                int newValue = oldValue | mask;
                data.set(offset, newValue);
                if (ty > 2) {
                    // page 2:
                    vdppointer += 256*8;
                }
                changes.add(0, new Pair<>(vdppointer, oldValue));
//                System.out.println("tx,ty: " + tx + "," + ty + "\tpx,py: " + px + "," + py + "\tname: " + name + "\toffset: " + offset + "\tmask: " + mask + "\tvalue: " + oldValue + " -> " + newValue);
            }
        }
        
        data.add(changes.size());
        for(Pair<Integer, Integer> change:changes) {
            data.add(change.m_a%256);
            data.add(change.m_a/256);
            data.add(change.m_b);
        }
        
        String outputFileName2 = "src/autogenerated/travel-cutscene";
        Z80Assembler.dataToBinary(data, outputFileName2+".bin");    
        ZX0Wrapper.main(outputFileName2+".bin", outputFileName2+".zx0", true, false);
        
    }

    
    private static int getTileIfPossible(
            int x, int y,
            BufferedImage img, List<List<Integer>> tiles) throws Exception {
        List<Integer> tileData = new ArrayList<>();
        for(int i = 0;i<8;i++) {
            List<Integer> colors = new ArrayList<>();
            List<Integer> allColors = new ArrayList<>();
            for(int j = 0;j<8;j++) {
                int color = ConvertPatternsToAssembler.findMSXColor(x*8+j, y*8+i, img, TOLERANCE);
                if (!allColors.contains(color)) {
                    allColors.add(color);
                }
                colors.add(color);
            }
//            System.out.println(allColors);
            if (allColors.size()>2) {
                // We need a sprite here:
                for(int j = 0;j<8;j++) {
                    if (colors.get(j) == 8) {  // medium red
                        colors.set(j, 14);  // grey
                    } else {
                        img.setRGB(x*8+j, y*8+i, 0);
                    }
                }
                allColors.remove((Integer)8);
            } else {
                for(int j = 0;j<8;j++) {
                    img.setRGB(x*8+j, y*8+i, 0);
                }
            }
            Collections.sort(allColors);
            while(allColors.size()<2) allColors.add(14);
            
            // pattern:
            int pattern = 0;
            for(int j = 0;j<8;j++) {
                pattern *= 2;
                if (allColors.indexOf(colors.get(j)) == 1) {
                    pattern += 1;
                }
            }
            tileData.add(pattern);
            
            // attributes:
            int attributes = allColors.get(0) + allColors.get(1)*16;
            tileData.add(attributes);
        }
        
        // Check if the tile already exists:
        int found = -1;
        for(int i = 0;i<tiles.size();i++) {
            List<Integer> tile2 = tiles.get(i);
            boolean match = true;
            for(int j = 0;j<16;j++) {
                if (!tileData.get(j).equals(tile2.get(j))) {
                    match = false;
                    break;
                }
            }
            if (match) {
                found = i;
                break;
            }
        }
        if (found == -1) {
            found = tiles.size();
            tiles.add(tileData);
        }
        return found;       
    }
}
