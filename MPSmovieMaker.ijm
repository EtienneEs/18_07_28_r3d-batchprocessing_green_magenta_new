// @File (label="source directory",style="directory") dir1
// @File (label="destination directory",style="directory") dir2
// @String (label="open only files of type",choices={".r3d", ".ome.tif",  ".mvd2",".lif",".sld",".czi", ".ics"}) infiletype
// @String (label="Save an additional output-file besides the avi file ?", choices={"No","ICS-1","ICS-2","OME-TIFF", "CellH5"}) outfiletype
// @String (label="auto processing ?",choices={"auto", "manuel"}) manuelc

// -------------------------------------------------------------------------------
// This is a batch-processing script, it opens Bio-formats supported files, allows rotation
// and exports the result in a Bio-formats-supported file and an .avi file.
// This script was written by Etienne Schmelzer with support by Gordian Born and Kai Schleicher.
// -------------------------------------------------------------------------------

input= dir1+"\\"
output=dir2+"\\"

if (manuelc == "auto") {
				setBatchMode(true);
}

// check user selection and translate into proper file endings
// rotation = parseInt(rotation);
if (outfiletype == "ICS-1") {
    tgt_suffix = ".ids";
} else if (outfiletype == "ICS-2") {
    tgt_suffix = ".ics";
} else if (outfiletype == "OME-TIFF") {
    tgt_suffix = ".ome.tif";
} else if (outfiletype == "CellH5") {
    tgt_suffix = ".ch5";
}
list = getFileList(dir1);
for (i=0; i<list.length; i++) {
    // only open an image with the requested extension:
    if(endsWith(list[i], infiletype)){

        incoming = dir1+File.separator+list[i];

        //open the image at position i as a hyperstack using the bio-formats
        //opens all images of a container file (e.g. *.lif, *.sld)
       	run("Bio-Formats Importer", "open=[" + incoming + "] color_mode=Custom open_all_series view=Hyperstack stack_order=XYCZT use_virtual_stack series_0_channel_0_red=0 series_0_channel_0_green=255 series_0_channel_0_blue=0 series_0_channel_1_red=255 series_0_channel_1_green=0 series_0_channel_1_blue=255");

    	// get image IDs of all open images:
    	all = newArray(nImages);
    	//print(nImages + " Datasets will be processed");
    	openwindows=nImages;

    	for (k=0; k < openwindows; k++) {
            selectImage(k+1);
            all[k] = getImageID;
            title=getTitle();
			getDimensions(width, height, channels, slices, frames_o);
			int = Stack.getFrameInterval();
			//print("The stack-frame interval is " + int +" seconds");
			run("Z Project...", "projection=[Max Intensity] all");
			Stack.setDisplayMode("composite");
			run("Enhance Contrast", "saturated=0.35");
			Stack.setChannel(2);
			run("Enhance Contrast", "saturated=0.35");
			title_max=getTitle();

			if (manuelc == "manuel") {
				skip=getBoolean("Do you want to crop?");
				if (skip==true) {
					waitForUser("Please select area");
					run("Crop");
					print(title_max + " has been cropped");
					run("Make Composite", "display=Composite");
				}

			}

			run("Duplicate...", "duplicate");
			title_duplicate=getTitle();
			selectWindow(title_duplicate);
			Stack.setDisplayMode("composite");
			selectWindow(title_max);
			run("Split Channels");
			lista = "C1-" + title_max;
			listb = "C2-" + title_max;
			selectWindow(listb);
			run("Invert", "stack");
			selectWindow(lista);
			run("Invert", "stack");
			run("Enhance Contrast", "saturated=0.35");
			run("Grays");
			selectWindow(listb);
			run("Enhance Contrast", "saturated=0.35");
			run("Grays");
			if (manuelc == "manuel") {
				waitForUser("please pick your brightness");
			}

			//skip=getBoolean("Do you want to proceed?");
			//if (skip==true) {
			selectWindow(lista);
			run("RGB Color");
			selectWindow(listb);
			run("RGB Color");
			selectWindow(title_duplicate);
			run("RGB Color", "frames");
			RGB_title_duplicate = getTitle();
			run("Combine...", "stack1=["+ lista +"] stack2=["+ listb +"]");
			f="Combined Stacks";
			run("Combine...", "stack1=["+ RGB_title_duplicate +"] stack2=["+ f +"]");

			//z=getNumber("What is the Time Interval of"+title_max+" ?", int);
			z = int;
			run("Label...", "format=00:00:00 starting=0 interval="+z+" x=10 y=25 font=18");

			if (manuelc == "manuel") {
				selectWindow("Combined Stacks");
				getDimensions(width, height, channels, slices, frames);
				makeRectangle((width/3.6), (height-50), 10, 10);
				waitForUser("mark where to enter scale bar");
			}	else {
				selectWindow("Combined Stacks");
				getDimensions(width, height, channels, slices, frames);
				makeRectangle((width/3.6), (height-50), 10, 10);
			}
			run("Scale Bar...", "width=5 height=4 font=14 color=White background=None location=[At Selection] overlay");

			if (manuelc == "manuel") {
				waitForUser("Press OK to save");
			}
			title = replace(title,infiletype,"");
            title = replace(title," ","_");
            title = replace(title,"/","-");
            int = Stack.getFrameInterval();
            run("Label...", "format=00:00:00 starting=0 interval="+int+" x=10 y=25 font=18");
            selectWindow("Combined Stacks");

            outFile = dir2 +File.separator+ title;

            if (outfiletype != "No") {
            	outFile2 = outFile + tgt_suffix;
            	print("Saving of " + outFile2);
            	run("Bio-Formats Exporter", "save=[" + outFile2 + "]");
            }
    		if (frames_o == 1) {
    			print("Saving of " + outFile +".ome.tif");
    			run("Bio-Formats Exporter", "save=["+ outFile +".ome.tif]");
    		} else {
    			print("Saving of " + outFile +".avi");
    			run("AVI... ", "compression=JPEG frame=3 save=["+ outFile +".avi]");
    		}
            print("Done");
            run("Close All");
    	}
        run("Close All");
    }
}

print(" ");
print("All done");