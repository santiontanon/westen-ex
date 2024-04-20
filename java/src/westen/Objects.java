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
public class Objects {
    public static int TOLERANCE = 64;
    
    public static void main(String args[]) throws Exception
    {        
        String objectsImageFileName = "data/objects.png";
        String outputFolder = "src/autogenerated/objects";
        
        BufferedImage img = ImageIO.read(new File(objectsImageFileName));
        
        ConvertPatternsToAssembler.MSX1Palette = Walls.MSX1Palette;

        generateObject(img, 0, 0, 2, 2, 
                       8, 8, 8, 1, 1, outputFolder + "/stool");
        generateObject(img, 2, 0, 2, 3,
                       8, 8, 16, 1, 2, outputFolder + "/chair-right");
        generateObject(img, 4, 0, 2, 3,
                       8, 8, 16, 1, 2, outputFolder + "/chair-left");
        generateObject(img, 6, 0, 4, 3, 
                       16, 16, 8, 2, 1, outputFolder + "/table-1");
        generateObject(img, 10, 0, 4, 3, 
                       16, 16, 8, 2, 1, outputFolder + "/table-2");
        generateObject(img, 0, 2, 2, 3,
                       10, 8, 16, 1, 2, outputFolder + "/tombstone");        
        
        generateObject(img, 0, 7, 2, 5,
                       16, 16, 64, -1, 4, outputFolder + "/doorframe-bookshelf-left");
        generateObject(img, 2, 7, 2, 5,
                       16, 16, 64, 2, 3, outputFolder + "/doorframe-bookshelf-right");
        generateObject(img, 4, 7, 2, 5,
                       16, 16, 64, -1, 4, outputFolder + "/doorframe-brick-left");
        generateObject(img, 6, 7, 2, 5,
                       16, 16, 64, 2, 4, outputFolder + "/doorframe-brick-right");
        
        generateObject(img, 7, 3, 4, 5, 
                       16, 16, 16, 2, 2, outputFolder + "/stairs-nw-1");
        generateObject(img, 11, 3, 4, 4, 
                       16, 16, 8, 2, 1, outputFolder + "/stairs-nw-2");
        
        generateObject(img, 2, 3, 2, 2, 
                       8, 8, 4, 1, 1, outputFolder + "/yellow-key");

        generateObject(img, 8, 8, 2, 5, 
                       8, 16, 48, 1, 4, outputFolder + "/door-left");
        generateObject(img, 10, 8, 2, 5, 
                       16, 8, 48, 1, 4, outputFolder + "/door-right");
        
        generateObject(img, 4, 3, 2, 2, 
                       8, 8, 4, 1, 1, outputFolder + "/gun");
        
        {
            List<Integer> additionalData = new ArrayList<>();
            getData(img, 12, 12, 7, additionalData);
            generateObjectInternal(img, 12, 7, 3, 5, 
                                   16, 4, 32, 1, 4, outputFolder + "/clock-right",
                                   additionalData);
        }

        generateObject(img, 14, 0, 2, 3, 
                       2, 16, 16, 2, 2, outputFolder + "/fence");
        generateObject(img, 16, 0, 2, 2, 
                       8, 8, 8, 1, 1, outputFolder + "/stone");
        generateObject(img, 18, 0, 1, 2, 
                       4, 4, 16, 0, 2, outputFolder + "/flower");
        generateObject(img, 16, 2, 2, 5, 
                       8, 8, 64, 1, 4, outputFolder + "/column");
        generateObject(img, 19, 0, 4, 3, 
                       16, 16, 4, 2, 1, outputFolder + "/platform1");
        generateObject(img, 23, 0, 4, 3, 
                       16, 16, 4, 2, 1, outputFolder + "/platform2");
        
        generateObject(img, 15, 7, 2, 5,
                       16, 16, 64, 2, 4, outputFolder + "/doorframe-entrance-right");

//        generateObject(img, 18, 5, 4, 3,
//                       16, 16, 8, 2, 1, outputFolder + "/stair-steps-right");
//        generateObject(img, 22, 5, 3, 4,
//                       4, 16, 24, 2, 3, outputFolder + "/stair-steps-rail");
        generateObject(img, 18, 23, 4, 3,
                       16, 9, 8, 1, 1, outputFolder + "/stair-steps-right");
        generateObject(img, 22, 23, 2, 4,
                       4, 8, 24, 1, 3, outputFolder + "/stair-steps-rail");
        
        generateObject(img, 17, 8, 2, 5,
                       16, 16, 64, -1, 4, outputFolder + "/doorframe-wood-left");
        generateObject(img, 19, 8, 2, 5,
                       16, 16, 64, 3, 4, outputFolder + "/doorframe-wood-right");

        generateObject(img, 27, 0, 3, 3, 
                       16, 8, 10, 1, 1, outputFolder + "/chest");
        generateObject(img, 25, 3, 3, 3, 
                       16, 1, 8, 1, 1, outputFolder + "/painting-right");
        generateObject(img, 30, 0, 2, 3, 
                       8, 8, 20, 1, 2, outputFolder + "/hanger");
//        generateObject(img, 28, 3, 2, 3, 
//                       8, 8, 16, 1, 2, outputFolder + "/vase");
        generateObject(img, 0, 32, 2, 3, 
                       8, 8, 16, 1, 2, outputFolder + "/vase");
        generateObject(img, 21, 9, 3, 4, 
                       16, 8, 16, 1, 2, outputFolder + "/night-table");
        
        generateObject(img, 24, 9, 4, 4, 
                       16, 16, 14, 2, 2, outputFolder + "/dining-table-1");
        generateObject(img, 28, 9, 4, 4, 
                       16, 16, 14, 2, 2, outputFolder + "/dining-table-2");
        
        generateObject(img, 28, 6, 4, 3, 
                       16, 16, 9, 2, 1, outputFolder + "/crate");
        generateObject(img, 0, 12, 4, 4, 
                       16, 16, 12, 2, 2, outputFolder + "/couch");

        generateObject(img, 4, 12, 4, 5, 
                       16, 1, 8, 2, 3, outputFolder + "/window-ne");
        generateObject(img, 30, 3, 2, 3, 
                       8, 8, 16, 1, 2, outputFolder + "/barrel");
        generateObject(img, 13, 12, 3, 6, 
                       8, 16, 32, 2, 4, outputFolder + "/shelves-nw");
        generateObject(img, 8, 13, 4, 5, 
                       10, 20, 18, 3, 3, outputFolder + "/sink");
        
        generateObject(img, 20, 3, 2, 2, 
                       6, 6, 2, 1, 1, outputFolder + "/letter3");
        generateObject(img, 22, 3, 2, 2, 
                       8, 8, 6, 1, 1, outputFolder + "/lamp");
        generateObject(img, 0, 16, 2, 2, 
                       8, 8, 6, 1, 1, outputFolder + "/oil");
        generateObject(img, 25, 6, 3, 3, 
                       16, 1, 8, 1, 1, outputFolder + "/safe-right");
        generateObject(img, 16, 15, 4, 3, 
                       8, 8, 8, 2, 2, outputFolder + "/spiderweb");
        generateObject(img, 20, 13, 2, 3, 
                       12, 8, 16, 1, 2, outputFolder + "/toilet");
        generateObject(img, 22, 13, 3, 3, 
                       8, 16, 10, 2, 1, outputFolder + "/chest2");
        generateObject(img, 2, 32, 3, 3, 
                       8, 16, 10, 2, 1, outputFolder + "/chest-gun");
        generateObject(img, 25, 13, 4, 3, 
                       24, 10, 8, 1, 1, outputFolder + "/bathtub");
        generateObject(img, 29, 13, 2, 3, 
                       8, 8, 16, 1, 2, outputFolder + "/gramophone");
        generateObject(img, 4, 19, 2, 3, 
                       8, 6, 16, 1, 2, outputFolder + "/violin");
        generateObject(img, 2, 16, 2, 2, 
                       8, 8, 6, 1, 1, outputFolder + "/heart");
        generateObject(img, 0, 18, 2, 2, 
                       8, 6, 6, 1, 1, outputFolder + "/bookstack");
        generateObject(img, 22, 16, 4, 4, 
                       16, 16, 14, 2, 2, outputFolder + "/writing-table-1");
        generateObject(img, 26, 16, 4, 4, 
                       16, 16, 14, 2, 2, outputFolder + "/writing-table-2");
        generateObject(img, 2, 18, 2, 2, 
                       6, 6, 4, 1, 1, outputFolder + "/book");
        generateObject(img, 0, 20, 4, 4, 
                       16, 16, 16, 2, 2, outputFolder + "/tall-crate");
        generateObject(img, 30, 16, 2, 3, 
                       8, 8, 18, 1, 2, outputFolder + "/tall-stool");
        generateObject(img, 4, 22, 2, 2, 
                       8, 8, 8, 1, 1, outputFolder + "/candle");
        generateObject(img, 6, 21, 3, 3, 
                       16, 16, 1, -2, -1, outputFolder + "/pentagram1");
        generateObject(img, 9, 21, 3, 3, 
                       16, 16, 1, -2, -1, outputFolder + "/pentagram2");
        generateObject(img, 0, 24, 4, 6, 
                       16, 16, 64, 2, 4, outputFolder + "/brickwall");
        generateObject(img, 4, 24, 3, 6, 
                       4, 16, 64, 2, 4, outputFolder + "/grid");
        generateObject(img, 17, 18, 2, 5, 
                       8, 8, 64, 1, 4, outputFolder + "/column-blue");
        generateObject(img, 4, 17, 4, 2, 
                       16, 16, 4, 2, 0, outputFolder + "/spikes");
        generateObject(img, 7, 24, 4, 3, 
                       16, 16, 8, 2, 1, outputFolder + "/blue-brick");        
        {
            List<Integer> additionalData = new ArrayList<>();
            getData(img, 15, 5, 6, additionalData);
            getData(img, 15, 6, 6, additionalData);
            generateObjectInternal(img, 15, 3, 1, 2, 
                                   4, 4, 8, 1, 1, outputFolder + "/torch",
                                   additionalData);
        }
        generateObject(img, 8, 18, 2, 1, 
                       10, 6, 4, 1, 0, outputFolder + "/bones1");
        generateObject(img, 10, 18, 2, 1, 
                       10, 6, 4, 1, 0, outputFolder + "/bones2");
        generateObject(img, 6, 19, 2, 1, 
                       10, 6, 4, 1, 0, outputFolder + "/bones3");
        
        generateObject(img, 22, 20, 4, 3, 
                       16, 20, 12, 2, 1, outputFolder + "/coffin-1");
        generateObject(img, 26, 20, 3, 3, 
                       16, 8, 12, 1, 1, outputFolder + "/coffin-2");
        generateObject(img, 8, 19, 2, 2, 
                       6, 4, 2, 1, 1, outputFolder + "/gun-key");       
        generateObject(img, 20, 16, 2, 5, 
                       16, 8, 48, 0, 4, outputFolder + "/door-vampire-right");        
        generateObject(img, 11, 24, 4, 3, 
                       20, 10, 1, -2, -1, outputFolder + "/red-carpet");
        generateObject(img, 15, 24, 3, 3, 
                       8, 16, 10, 2, 1, outputFolder + "/altar");
        generateObject(img, 30, 19, 2, 3, 
                       2, 16, 20, 1, 2, outputFolder + "/cross");        
        generateObject(img, 10, 19, 2, 2, 
                       8, 8, 4, 1, 1, outputFolder + "/green-key");

//        generateObject(img, 7, 27, 4, 3, 
//                       16, 14, 1, 2, 1, outputFolder + "/carpet-1");
//        generateObject(img, 11, 27, 2, 3, 
//                       16, 14, 1, 0, 0, outputFolder + "/carpet-2");
        generateObject(img, 5, 32, 4, 3, 
                       16, 14, 1, 2, 0, outputFolder + "/carpet-1");
        generateObject(img, 9, 32, 4, 3, 
                       16, 14, 1, 2, 0, outputFolder + "/carpet-2");
        
        {
            List<Integer> additionalData = new ArrayList<>();
            getData(img, 28, 23, 8, additionalData);
            getData(img, 28, 24, 8, additionalData);
            generateObjectInternal(img, 24, 23, 4, 5, 
                                   8, 24, 20, 3, 3, outputFolder + "/fireplace",
                                   additionalData);
        }
        
        generateObject(img, 13, 27, 2, 5, 
                       1, 16, 32, 1, 3, outputFolder + "/window-left");
        generateObject(img, 15, 27, 4, 4, 
                       16, 16, 8, 2, 2, outputFolder + "/bed-1");
        generateObject(img, 19, 27, 4, 3, 
                       16, 16, 8, 2, 1, outputFolder + "/bed-2");
        generateObject(img, 19, 21, 2, 2, 
                       6, 6, 4, 1, 1, outputFolder + "/diary1");
        generateObject(img, 0, 30, 2, 2, 
                       6, 6, 4, 1, 1, outputFolder + "/diary2");
        generateObject(img, 2, 30, 2, 2, 
                       6, 6, 4, 1, 1, outputFolder + "/diary3");

        generateObject(img, 21, 21, 1, 2, 
                       8, 8, 8, 0, 1, outputFolder + "/lab-bottle");
        generateObject(img, 23, 28, 4, 3, 
                       12, 24, 8, 3, 1, outputFolder + "/lab-bottles");
        
        generateObject(img, 6, 30, 2, 2, 
                       6, 6, 4, 1, 1, outputFolder + "/lab-notes");
        generateObject(img, 8, 30, 2, 2, 
                       6, 6, 4, 1, 1, outputFolder + "/hammer");
        generateObject(img, 28, 25, 4, 3, 
                       16, 16, 9, 2, 1, outputFolder + "/crate-breakable");
        generateObject(img, 10, 30, 2, 2, 
                       6, 6, 4, 1, 1, outputFolder + "/garlic");
        generateObject(img, 19, 30, 2, 2, 
                       6, 6, 4, 1, 1, outputFolder + "/stake");
        
        generateObject(img, 29, 22, 2, 3, 
                       16, 2, 16, 0, 2, outputFolder + "/fence2");
        
        generateObject(img, 0, 37, 4, 3, 
                       16, 20, 12, 2, 1, outputFolder + "/coffin-vampire-1");
        {
            List<Integer> additionalData = new ArrayList<>();
            getData(img, 7, 37, 16, additionalData);
            getData(img, 8, 37, 16, additionalData);
            getData(img, 9, 37, 16, additionalData);
            getData(img,10, 37, 16, additionalData);
            generateObjectInternal(img, 4, 37, 3, 4, 
                                   16, 8, 12, 1, 2, outputFolder + "/coffin-vampire-2",
                                   additionalData);
        }
        
        // EX objects:
        generateObject(img, 13, 32, 3, 6, 
                       8, 16, 32, 2, 4, outputFolder + "/bookshelves-nw");
        generateObject(img, 16, 31, 3, 4, 
                       8, 16, 16, 2, 2, outputFolder + "/night-table-nw");
        generateObject(img, 7, 27, 2, 2, 
                       8, 6, 6, 1, 1, outputFolder + "/bookstack-home");
        
        generateObject(img, 9, 27, 2, 2, 
                       8, 8, 10, 1, 1, outputFolder + "/luggage");
        generateObject(img, 11, 27, 2, 2, 
                       8, 8, 4, 1, 1, outputFolder + "/newspaper");
        generateObject(img, 0, 35, 2, 2, 
                       8, 8, 4, 1, 1, outputFolder + "/university-notes");
        
        generateObject(img, 19, 32, 3, 3, 
                       8, 16, 5, 2, 1, outputFolder + "/doorstep");

        generateObject(img, 11, 35, 1, 5, 
                       4, 4, 32, 0, 4, outputFolder + "/streetlamp");
        generateObject(img, 2, 35, 2, 2, 
                       12, 4, 8, 0, 1, outputFolder + "/streetlamp-wall");

        generateObject(img, 29, 30, 3, 10, 
                       16, 16, 80, 0, 8, outputFolder + "/street-corner");
        generateObject(img, 22, 32, 1, 6, 
                       4, 4, 48, 0, 5, outputFolder + "/watkins-column");
        generateObject(img, 23, 31, 6, 5, 
                       4, 48, 16, 5, 2, outputFolder + "/watkins-sign");
        generateObject(img, 20, 35, 2, 6, 
                       1, 16, 48, 0, 5, outputFolder + "/watkins-door");

        generateObject(img, 0, 41, 6, 6, 
                       24, 28, 32, 3, 3, outputFolder + "/horsecar");
        {
            List<Integer> additionalData = new ArrayList<>();
            getData(img, 11, 41, 24, additionalData);
            getData(img, 12, 41, 24, additionalData);
            getData(img, 13, 41, 24, additionalData);
            generateObjectInternal(img, 6, 41, 5, 7, 
                                   12, 32, 24, 3, 4, outputFolder + "/horse",
                                   additionalData);
        }

        generateObject(img, 11, 44, 2, 4, 
                       12, 10, 16, 1, 2, outputFolder + "/beggar");
        generateObject(img, 7, 39, 1, 2, 
                       4, 4, 6, 1, 1, outputFolder + "/beggar-bag");
        generateObject(img, 4, 35, 4, 2, 
                       20, 12, 6, 2, 0, outputFolder + "/beggar-dead");
        generateObject(img, 24, 36, 5, 6, 
                       8, 32, 80, 4, 3, outputFolder + "/bookstore-clerk");
        generateObject(img, 16, 35, 2, 4, 
                       6, 6, 24, 1, 3, outputFolder + "/choffeur");
        
        generateObject(img, 8, 39, 2, 2, 
                       8, 8, 4, 1, 1, outputFolder + "/lucy-torn-note");
        
        generateObject(img, 18, 35, 2, 2, 
                       8, 8, 0, 1, 0, outputFolder + "/secret-staircase");

        generateObject(img, 12, 38, 4, 3, 
                       20, 8, 9, 1, 1, outputFolder + "/sarcophagus");

        generateObject(img, 14, 41, 2, 7,
                       16, 16, 64, -1, 5, outputFolder + "/doorframe-gothic-left");
        generateObject(img, 16, 41, 2, 7,
                       16, 16, 64, 3, 5, outputFolder + "/doorframe-gothic-right");

        generateObject(img, 18, 41, 4, 8,
                       14, 18, 64, 2, 6, outputFolder + "/vlad-statue");
        generateObject(img, 18, 37, 2, 4,
                       6, 8, 24, 1, 3, outputFolder + "/suit-of-armor-nw");
        generateObject(img, 22, 38, 2, 4,
                       8, 6, 24, 1, 3, outputFolder + "/suit-of-armor-ne");
        generateObject(img, 28, 42, 2, 4,
                       8, 6, 24, 1, 3, outputFolder + "/suit-of-armor-sw");

//        generateObject(img, 22, 42, 2, 7,
//                       12, 2, 64, 1, 7, outputFolder + "/banner-ne");
        generateObject(img, 24, 42, 2, 5,
                       12, 1, 64, 1, 4, outputFolder + "/banner-ne");
        generateObject(img, 26, 42, 2, 5,
                       1, 12, 64, 1, 4, outputFolder + "/banner-nw");
        
        generateObject(img, 0, 47, 4, 4, 
                       16, 16, 14, 2, 2, outputFolder + "/dining-table-middle");
        generateObject(img, 30, 40, 2, 3,
                       8, 8, 16, 1, 2, outputFolder + "/chair-ne");
        generateObject(img, 30, 43, 2, 3,
                       8, 8, 16, 1, 2, outputFolder + "/chair-sw");
        generateObject(img, 4, 47, 2, 5, 
                       8, 16, 48, 1, 4, outputFolder + "/door-vampire-nw");        
        generateObject(img, 6, 48, 2, 2, 
                       8, 8, 8, 1, 1, outputFolder + "/coin-pile");        
        generateObject(img, 8, 48, 2, 2, 
                       8, 4, 4, 1, 1, outputFolder + "/puzzle-box");
        generateObject(img, 28, 46, 4, 4, 
                       16, 16, 14, 2, 2, outputFolder + "/tall-black-brick");
        generateObject(img, 12, 48, 6, 5, 
                       30, 14, 16, 2, 2, outputFolder + "/desk-ne");
        generateObject(img, 0, 51, 2, 2,
                       6, 6, 4, 1, 1, outputFolder + "/vlad-diary");
        generateObject(img, 24, 47, 4, 4, 
                       16, 16, 10, 2, 2, outputFolder + "/black-stairs-nw");
        generateObject(img, 0, 53, 2, 3,
                       1, 12, 16, 1, 2, outputFolder + "/mirror");
        generateObject(img, 2, 53, 2, 3,
                       12, 1, 16, 1, 2, outputFolder + "/mirror-ne");
        generateObject(img, 4, 52, 2, 2,
                       6, 6, 2, 1, 1, outputFolder + "/mirror-clue");

        generateObject(img, 30, 50, 2, 5, 
                       16, 8, 48, 1, 4, outputFolder + "/door-prison-ne");

        generateObject(img, 144/8, 408/8, 8, 5, 
                       32, 32, 12, 4, 1, outputFolder + "/vlad-ritual");

        generateObject(img, 26, 51, 3, 6, 
                       16, 4, 64, 1, 4, outputFolder + "/grid2");

        generateObject(img, 88/8, 424/8, 2, 4, 
                       8, 8, 24, 1, 3, outputFolder + "/skeleton-ne");
        generateObject(img, 20, 49, 2, 2,
                       6, 6, 4, 1, 1, outputFolder + "/cauldron");
        generateObject(img, 104/8, 424/8, 4, 4,
                       20, 8, 18, 1, 2, outputFolder + "/weapon-rack");

        generateObject(img, 32, 0, 3, 6, 
                       8, 16, 64, 2, 4, outputFolder + "/brickwall-thin");
        
        {
            List<Integer> additionalData = new ArrayList<>();
            getData(img, 296/8, 0, 16, additionalData);
            getData(img, 304/8, 0, 16, additionalData);
            generateObjectInternal(img, 280/8, 0, 2, 2, 
                                   8, 8, 12, 1, 1, outputFolder + "/switch",
                                   additionalData);
        }

        generateObject(img, 296/8, 2, 2, 2,
                       2, 2, 12, 1, 1, outputFolder + "/arrow-shooter");
        
        generateObject(img, 22, 49, 2, 2,
                       6, 6, 4, 1, 1, outputFolder + "/skeleton-key");

        generateObject(img, 312/8, 0, 5, 3,
                       10, 16, 1, 2, 0, outputFolder + "/open-grave");
        generateObject(img, 312/8, 3, 2, 2,
                       6, 6, 4, 1, 1, outputFolder + "/clay");
        generateObject(img, 32, 8, 2, 3,
                       8, 8, 12, 1, 2, outputFolder + "/log-book");

        generateObject(img, 336/8, 48/8, 2, 2,
                       6, 6, 4, 1, 1, outputFolder + "/franky-note");
        
    }
    
    
    public static void getData(BufferedImage img, int x, int y, int rows, List<Integer> data)
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
                } else if (pixel == 0 || pixel == 1) {
                    // outline:
                } else {
                    orMask += 1;
                    // object color:
                    if (!colors.contains(pixel)) {
                        colors.add(pixel);
                    }
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


    public static void generateObject(
            BufferedImage img, 
            int x, int y, int tile_width, int tile_height, 
            int object_width, int object_height, int object_z_height, 
            int x_offset, int y_offset,
            String outputFileName) throws Exception
    {
        generateObjectInternal(img, x, y, tile_width, tile_height,
                               object_width, object_height, object_z_height,
                               x_offset, y_offset, outputFileName,
                               new ArrayList<>());
    }
    
    
    public static void generateObjectInternal(
            BufferedImage img, 
            int x, int y, int tile_width, int tile_height, 
            int object_width, int object_height, int object_z_height, 
            int x_offset, int y_offset,
            String outputFileName,
            List<Integer> additionalData) throws Exception
    {        
        List<Integer> data = new ArrayList<>();
        data.add(tile_width);
        data.add(tile_height);
        data.add(object_width);
        data.add(object_height);
        data.add(object_z_height);
        data.add(x_offset);
        data.add(y_offset);
        
        System.out.println(outputFileName + ":");
        for(int i = 0;i<tile_width;i++) {
            List<Integer> columnData = new ArrayList<>();
            for(int j = 0;j<tile_height;j++) {
//                List<Integer> attributes = new ArrayList<>();
                getData(img, x+i, y+j, 8, columnData);
            }
            System.out.println("column " + i + ", columnData: " + columnData);
//            data.add(columnData.size()+1);
            data.addAll(columnData);
        }
        
        data.addAll(additionalData);
        
        int l = data.size();
        data.add(0, l/256);
        data.add(0, l%256);
        
        Z80Assembler.dataToBinary(data, outputFileName+".bin");    
        Pletter.intMain(new String[]{outputFileName+".bin", outputFileName+".plt"});
        ZX0Wrapper.main(outputFileName+".bin", outputFileName+".zx0", true, false);        
    }
    
}
