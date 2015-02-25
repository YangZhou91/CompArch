/**
 * ECSE 415 Project, Assembler Implementation
 * Author: Yang Zhou
 * Group 6
 * Members: Yukun Su, Yang Zhou, Wei Sing Ta, Lena Hsieh
 */

import java.util.Scanner;


public class ReducedMIPS {
	
	public static void main(String[] args) {
		Scanner sc = new Scanner(System.in);
		String filename;
		
		// Get filename from command line if provided, else use stdin
		if (args.length > 0) {
            filename = args[0];
            for (int i=1; i<args.length; i++) {
                // Set debug mode if command line option is set
                if (args[i].equals("-d")) Assembler.setDebugMode(true);
                // else if (args[i].equals("-p")) printToConsole = true;
            }
		}
		else {
			System.out.print("Enter name of file to assemble: ");
			filename = sc.next();
		}
		
		Assembler.assembleFile(filename);
		
		sc.close();

	}
	
}
