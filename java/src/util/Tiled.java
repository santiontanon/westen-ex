/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package util;

import java.io.FileWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.StringTokenizer;
import org.jdom.Attribute;
import org.jdom.Element;
import org.jdom.input.SAXBuilder;

/**
 *
 * @author santi
 */
public class Tiled {
    public static int[][] loadTMXtileData(String fileName) throws Exception
    {
        Element xml = new SAXBuilder().build(fileName).getRootElement();
        int width = Integer.parseInt(xml.getAttributeValue("width"));
        int height = Integer.parseInt(xml.getAttributeValue("height"));
        int map[][] = new int[width][height];
        for(Object o:xml.getChildren("layer")) {
            Element layer_xml = (Element)o;
            Element data_xml = layer_xml.getChild("data");
            String data = data_xml.getValue();
            StringTokenizer st = new StringTokenizer(data, ",");
            for(int i = 0;i<height;i++) {
                for(int j = 0;j<width;j++) {
                    map[j][i] = Integer.parseInt(st.nextToken().trim())-1;
                }
            }
        }
        return map;
    }       
    
    
    public static List<HashMap<String, String>> loadTMXObjectData(String fileName, String layerName) throws Exception
    {
        Element xml = new SAXBuilder().build(fileName).getRootElement();
        List<HashMap<String, String>> objects = new ArrayList<>();
        for(Object l:xml.getChildren("objectgroup")) {
            Element layer_xml = (Element)l;
            if (layer_xml.getAttributeValue("name").equals(layerName)) {
                for(Object o:layer_xml.getChildren("object")) {
                    Element object_xml = (Element)o;
                    HashMap<String, String> object = new HashMap<>();
                    for(Object att:object_xml.getAttributes()) {
                        Attribute att_xml = (Attribute)att;
                        object.put(att_xml.getName(), att_xml.getValue());
                    }
                    for(Object pl:object_xml.getChildren("properties")) {
                        for(Object p:((Element)pl).getChildren("property")) {
                            Element property = (Element)p;
                            object.put(property.getAttributeValue("name"),
                                       property.getAttributeValue("value"));
                        }
                    }
                    objects.add(object);
                }        
                return objects;
            }
        }
        
        return null;
    }      
    
    
    public static void saveTMX(String fileName, int tiles[][], String tilesFileName) throws Exception
    {
        FileWriter fw = new FileWriter(fileName);
        
        fw.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
        fw.write("<map version=\"1.0\" orientation=\"orthogonal\" renderorder=\"right-down\" width=\""+tiles.length+"\" height=\""+tiles[0].length+"\" tilewidth=\"8\" tileheight=\"8\" nextobjectid=\"1\">");
        fw.write("<tileset firstgid=\"1\" name=\"moai-tiles\" tilewidth=\"8\" tileheight=\"8\" tilecount=\"256\" columns=\"16\">");
        fw.write("<image source=\""+tilesFileName+"\" width=\"128\" height=\"128\"/>");
        fw.write("</tileset>");
        fw.write("<layer name=\"Tile Layer 1\" width=\""+tiles.length+"\" height=\""+tiles[0].length+"\">");
        fw.write("<data encoding=\"csv\">");
        for(int i = 0;i<tiles[0].length;i++) {
            for(int j = 0;j<tiles.length;j++) {
                if (i == tiles[0].length-1 && j == tiles.length-1) {
                    fw.write("" + (tiles[j][i]+1));
                } else {
                    fw.write("" + (tiles[j][i]+1) + ",");
                }
            }
            fw.write("\n");
        }     
        fw.write("</data>");
        fw.write("</layer>");
        fw.write("</map>");
        
        fw.flush();
        fw.close();
    }    
}
