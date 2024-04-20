/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package westen;

import PNGtoMSX.ConvertPatternsToAssembler;
import java.awt.image.BufferedImage;
import java.io.File;
import java.util.ArrayList;
import java.util.List;
import javax.imageio.ImageIO;
import util.Pletter;
import util.Z80Assembler;
import util.ZX0Wrapper;

/**
 *
 * @author santi
 */
public class Enemies {
    
    public static int TOLERANCE = 64;
    public static int MSX1Palette[][]={
                                {0,0,0},              // Transparent 0 
                                {0,0,0},              // Black 1
                                {36,219,36},          // Medium Green 2
                                {109,255,109},        // Light Green 3
                                {36,36,255},          // Dark Blue 4
                                {73,109,255},         // Light Blue 5
                                {182,36,36},          // Dark Red 6
                                {73,219,255},         // Cyan
                                {255,36,36},          // Medium Red 8
                                {255,109,109},        // Light Red 9
                                {219,219,36},         // Dark Yellow 10
                                {219,219,146},        // Light Yellow 11
                                {36,146,36},          // Dark Green
                                {219,73,182},         // Magenta
                                {182,182,182},        // Grey
                                {255,255,255}};       // White        
    
    public static void main(String args[]) throws Exception
    {
        ConvertPatternsToAssembler.MSX1Palette = MSX1Palette;
                
        String objectsImageFileName = "data/enemies.png";
        String outputFolder = "src/autogenerated/enemies";
        
        BufferedImage img = ImageIO.read(new File(objectsImageFileName));    
        
        generateEnemyData(0, 0, "rat", img, outputFolder);
        generateEnemyData(32, 0, "spider", img, outputFolder);
        generateEnemyData(64, 0, "slime", img, outputFolder);
        generateEnemyData(96, 0, "bat", img, outputFolder);
        generateEnemyData(0, 32, "snake", img, outputFolder);
        generateEnemyData(32, 32, "arrow", img, outputFolder);
        
        generateSkeletonData(0,64, 160, 64, img, outputFolder);
        generateFrankyData(0,144, img, outputFolder);
    }

    
    // Assumes two animation frames
    private static void generateEnemyData(int x, int y, String name, BufferedImage img, String outputFolder) throws Exception
    {
        List<Integer> se_frame1 = getEnemyPixels(x, y, img);
        List<Integer> se_frame2 = getEnemyPixels(x, y+16, img);
        List<Integer> nw_frame1 = getEnemyPixels(x+16, y, img);
        List<Integer> nw_frame2 = getEnemyPixels(x+16, y+16, img);
        
        List<List<Integer>> sprites = new ArrayList<>();

        sprites.add(se_frame1);
        sprites.add(se_frame2);
        sprites.add(nw_frame1);
        sprites.add(nw_frame2);
        
        // Encode all sprites as data:
        List<Integer> data = new ArrayList<>();
        for(List<Integer> sprite:sprites) {
            spriteToBytes(sprite, data);
        }
        
        String outputFileName = outputFolder + "/" + name;
        Z80Assembler.dataToBinary(data, outputFileName+".bin");    
        Pletter.intMain(new String[]{outputFileName+".bin", outputFileName+".plt"});
        ZX0Wrapper.main(outputFileName+".bin", outputFileName+".zx0", true, false);        
    }
    
    
    public static void spriteToBytes(List<Integer> sprite, List<Integer> data)
    {
        int width = 16;
        if (sprite.size() == 16*24) width = 24;
        for(int jj = 0;jj<3;jj++) {
            for(int i = 0;i<16;i++) {
                int pattern = 0;
                int mask = 0;
                for(int j = 0;j<8;j++) {
                    int x = jj*8+j;
                    int pixel = (x>=width ? -1 : sprite.get(i*width + jj*8+j));
                    pattern *= 2;
                    mask *= 2;
                    if (pixel == -1) {
                        mask |= 1;
                    } else if (pixel == 15) {
                        pattern |= 1;
                    } else {
                        // black pixel, nothing to do
                    }
                }
                data.add(mask);
                data.add(pattern);
            }
        }
    }
    
    
    public static List<Integer> getEnemyPixels(int x, int y, BufferedImage img)
    {
        List<Integer> pixels = new ArrayList<>();
        
        for(int i = 0;i<16;i++) {
            for(int j = 0;j<16;j++) {
                int pixel = ConvertPatternsToAssembler.findMSXColor(x+j, y+i, img, TOLERANCE);
                pixels.add(pixel);
            }
        }
        return pixels;
    }
    
    
    // Input is a 16x16 sprite, output is a 24x16 sprite:
    public static List<Integer> shiftSprite(List<Integer> pixels, int x_offset)
    {
        List<Integer> pixels2 = new ArrayList<>();
        for(int i = 0;i<16;i++) {
            for(int j = 0;j<24;j++) {
                if (j<x_offset) {
                    pixels2.add(-1);
                } else if (j<x_offset+16) {
                    pixels2.add(pixels.get(i*16+j-x_offset));
                } else {
                    pixels2.add(-1);
                }
            }
        }
        
        return pixels2;
    }
    
    
    public static List<Integer> flipSprite(List<Integer> pixels)
    {
        List<Integer> pixels2 = new ArrayList<>();
        for(int i = 0;i<16;i++) {
            for(int j = 0;j<16;j++) {
                pixels2.add(pixels.get(i*16+15-j));
            }
        }
        
        return pixels2;
    }    
    
    
    /*
    x0, y0: definition of the skeleton when its not active
    x, y: skeleton when it's moving
    */
    public static void generateSkeletonData(int x, int y, 
                                            int x0, int y0,
                                            BufferedImage img, String outputFolder) throws Exception
    {
        int tile_width = 5;
        int tile_height = 5;
        String outputFileName = outputFolder + "/skeleton";

        {
            List<Integer> data = new ArrayList<>();
            data.add(tile_width);
            data.add(tile_height);
            data.add(12);
            data.add(12);
            data.add(32);
            data.add(3);
            data.add(4);

            // First frame data:
            for(int i = 0;i<tile_width;i++) {
                List<Integer> columnData = new ArrayList<>();
                for(int j = 0;j<tile_height;j++) {
    //                getDataSpecificColor(img, (x0/8)+i, (y0/8)+j, 8, columnData, 15);
                    Objects.getData(img, (x0/8)+i, (y0/8)+j, 8, columnData);
                }
                System.out.println("column " + i + ", columnData: " + columnData);
                data.addAll(columnData);
            }

            int l = data.size();
            data.add(0, l/256);
            data.add(0, l%256);

            Z80Assembler.dataToBinary(data, outputFileName+".bin");    
            Pletter.intMain(new String[]{outputFileName+".bin", outputFileName+".plt"});
            ZX0Wrapper.main(outputFileName+".bin", outputFileName+".zx0", true, false);
        }

        // Generate name tables and tile data:
        List<List<Integer>> tiles = new ArrayList<>();
        List<Integer> nameTables = new ArrayList<>();
        for(int i=0;i<2;i++) {
            for(int j=0;j<4;j++) {
                getSkeletonFrame(img,
                                 x + j * (tile_width*8),
                                 y + i * (tile_height*8), 
                                 tile_width,
                                 tile_height, nameTables, tiles);
            }
        }
        List<Integer> extraData = new ArrayList<>();
        extraData.addAll(nameTables);
        for(List<Integer> tile:tiles) {
            extraData.addAll(tile);
        }
        System.out.println("Skeleton extra data: " + extraData.size());
        String extraDataOutputFileName = outputFolder + "/skeleton-data";
        Z80Assembler.dataToBinary(extraData, extraDataOutputFileName+".bin");    
        Pletter.intMain(new String[]{extraDataOutputFileName+".bin", extraDataOutputFileName+".plt"});
        ZX0Wrapper.main(extraDataOutputFileName+".bin", extraDataOutputFileName+".zx0", true, false);
        
        // Skeleton sprites:
        String spritesOutputFileName = outputFolder + "/skeleton-sprites";
        List<Integer> spritesData = new ArrayList<>();
        for(int j=0;j<4;j++) {
            Sprites.getSpriteWithColor(8+8+j*40, 72, img, 9, spritesData);
            Sprites.getSpriteWithColor(8+8+j*40, 72+16, img, 9, spritesData);
        }
        for(int j=0;j<4;j++) {
            Sprites.getSpriteWithColor(8+j*40, 112, img, 9, spritesData);
            Sprites.getSpriteWithColor(8+j*40, 112+16, img, 9, spritesData);
        }

        for(int j = 0;j<512;j++) {
            System.out.print(spritesData.get(j) + " ");
            if (j%32 == 0) System.out.println("");
        }
        Z80Assembler.dataToBinary(spritesData, spritesOutputFileName+".bin");    
        Pletter.intMain(new String[]{spritesOutputFileName+".bin", spritesOutputFileName+".plt"});
        ZX0Wrapper.main(spritesOutputFileName+".bin", spritesOutputFileName+".zx0", true, false);        
    }
    
    
    public static void getSkeletonFrame(BufferedImage img,
                                        int x, int y, int tile_width, int tile_height,
                                        List<Integer> nameTables,
                                        List<List<Integer>> tiles) throws Exception
    {
        List<Integer> frameNameTable = new ArrayList<>();
        for(int j = 0;j<tile_width;j++) {
            for(int i = 0;i<tile_height;i++) {
                List<Integer> tile = new ArrayList<>();
                getDataSpecificColor(img, (x/8)+j, (y/8)+i, 8, tile, 15);
                int idx = tiles.indexOf(tile);
                if (idx == -1) {
                    idx = tiles.size();
                    tiles.add(tile);
                }
                frameNameTable.add(idx);
                nameTables.add(idx);
            }
        }
        System.out.println("frameNameTable: " + frameNameTable);
    }
    
    
    public static void getDataSpecificColor(BufferedImage img, int x, int y, int rows, List<Integer> data, int targetColor)
    {
        for(int jj = 0;jj<rows;jj++) {
            int andMask = 0;
            int orMask = 0;
            List<Integer> colors = new ArrayList<>();
            for(int k = 0;k<8;k++) {

                andMask *= 2;
                orMask *= 2;

                int pixel = ConvertPatternsToAssembler.findMSXColor(x*8+k, y*8+jj, img, TOLERANCE);

                if (pixel == -1) {
                    // transparent:
                    andMask += 1;
                } else if (pixel == targetColor) {
                    orMask += 1;
                    // object color:
                    if (!colors.contains(pixel)) {
                        colors.add(pixel);
                    }
                } else {
                    // outline:
                }
            }

            if (colors.size() > 1) {
                System.err.println("Two colors in the same object line!: " + colors);
                System.exit(1);
            }

            while(colors.size() < 2) {
                colors.add(0);
            }

            data.add(andMask);
            data.add(orMask);
            data.add(16*colors.get(0) + colors.get(1));
        }
    }    
    
    
    public static void generateFrankyData(int x, int y, 
                                          BufferedImage img, String outputFolder) throws Exception
    {
        int tile_width = 5;
        int tile_height = 6;
        String outputFileName = outputFolder + "/franky";

        {
            // Franky sprites:
            String spritesOutputFileName = outputFolder + "/franky-sprites";
            List<Integer> spritesData = new ArrayList<>();
            for(int i=0;i<4;i++) {
                int start_x = 16;
                if (i == 1 || i == 3) start_x = 8;
                for(int j=1;j<4;j+=2) {
//                for(int j=0;j<4;j++) {
                    getSpriteWithColorAndDelete(16+j*40, 144+i*48 - 3, img, 9, spritesData);
                    getSpriteWithColorAndDelete(start_x+j*40, 160+i*48 - 3, img, 2, spritesData);
                    getSpriteWithColorAndDelete(8+j*40, 176+i*48, img, 2, spritesData);
                }
            }

            for(int j = 0;j<spritesData.size();j++) {
                System.out.print(spritesData.get(j) + " ");
                if (j%32 == 0) System.out.println("");
            }
            Z80Assembler.dataToBinary(spritesData, spritesOutputFileName+".bin");    
            Pletter.intMain(new String[]{spritesOutputFileName+".bin", spritesOutputFileName+".plt"});
            ZX0Wrapper.main(spritesOutputFileName+".bin", spritesOutputFileName+".zx0", true, false);
        }
        
        {
            List<Integer> data = new ArrayList<>();
            data.add(tile_width);
            data.add(tile_height);
            data.add(14);
            data.add(14);
            data.add(40);
            data.add(3);
            data.add(4);

            // First frame data:
            for(int i = 0;i<tile_width;i++) {
                List<Integer> columnData = new ArrayList<>();
                for(int j = 0;j<tile_height;j++) {
                    Objects.getData(img, (40/8)+i, (240/8)+j, 8, columnData);
                }
                System.out.println("column " + i + ", columnData: " + columnData);
                data.addAll(columnData);
            }

            int l = data.size();
            data.add(0, l/256);
            data.add(0, l%256);

            Z80Assembler.dataToBinary(data, outputFileName+".bin");    
            Pletter.intMain(new String[]{outputFileName+".bin", outputFileName+".plt"});
            ZX0Wrapper.main(outputFileName+".bin", outputFileName+".zx0", true, false);
        }
        
        // Generate name tables and tile data:
        List<List<Integer>> tiles = new ArrayList<>();
        List<Integer> nameTables = new ArrayList<>();
        for(int i=0;i<4;i++) {
//            for(int j=0;j<4;j++) {
            for(int j=1;j<4;j+=2) {
                getFrankyFrame(img,
                               x + j * (tile_width*8),
                               y + i * (tile_height*8), 
                               tile_width,
                               tile_height, nameTables, tiles);
            }
        }
        List<Integer> extraData = new ArrayList<>();
        extraData.addAll(nameTables);
        for(List<Integer> tile:tiles) {
            extraData.addAll(tile);
        }
        System.out.println("Franky nametables: " + nameTables.size());
        System.out.println("Franky tiles: " + tiles.size() + " (" + (tiles.size()*24) + ")");
        System.out.println("Franky extra data: " + extraData.size());
        String extraDataOutputFileName = outputFolder + "/franky-data";
        Z80Assembler.dataToBinary(extraData, extraDataOutputFileName+".bin");    
        Pletter.intMain(new String[]{extraDataOutputFileName+".bin", extraDataOutputFileName+".plt"});
        ZX0Wrapper.main(extraDataOutputFileName+".bin", extraDataOutputFileName+".zx0", true, false);        
        
        ImageIO.write(img, "png", new File(outputFolder + "/enemies-modified.png"));        
    }
    
    
    public static void getSpriteWithColorAndDelete(int x,int y, BufferedImage img, int color, List<Integer> data)
    {
        for(int k = 0;k<2;k++) {
            for(int i = 0;i<16;i++) {
                int pattern = 0;
                for(int j = 0;j<8;j++) {
                    int pixel = 0;
                    if (y+i<img.getHeight()) {
                        pixel = ConvertPatternsToAssembler.findMSXColor(x+k*8+j, y+i, img, TOLERANCE);
                    }
//                    System.out.println(pixel);
                    pattern *= 2;
                    if (pixel == color) {
                        pattern ++;
                        img.setRGB(x+k*8+j, y+i, 0xff000000);  // delete the pixel
                    }
                }
//                System.out.println("");
                data.add(pattern);
            }
        }
    }    
    
        
    public static void getFrankyFrame(BufferedImage img,
                                      int x, int y, int tile_width, int tile_height,
                                      List<Integer> nameTables,
                                      List<List<Integer>> tiles) throws Exception
    {
        List<Integer> frameNameTable = new ArrayList<>();
        for(int j = 0;j<tile_width;j++) {
            for(int i = 0;i<tile_height;i++) {
                List<Integer> tile = new ArrayList<>();
//                getDataSpecificColor(img, (x/8)+j, (y/8)+i, 8, tile, 15);
                Objects.getData(img, (x/8)+j, (y/8)+i, 8, tile);
                int idx = tiles.indexOf(tile);
                if (idx == -1) {
                    idx = tiles.size();
                    tiles.add(tile);                    
                } else {
                    for(int ii = 0;ii<8;ii++) {
                        for(int jj = 0;jj<8;jj++) {
                            img.setRGB(x+j*8+jj, y+i*8+ii, 0xffffffff);  // mark as new tile
                        }
                    }                    
                }
                
                frameNameTable.add(idx);
                nameTables.add(idx);
            }
        }
        System.out.println("frameNameTable: " + frameNameTable);
    }
}