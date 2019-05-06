// @File(label="source directory",style="directory") dir0
// @File(label="destination directory",style="directory") dir2
// @String(label="Is the data in subfolders?", choices= {"Yes", "No"}) subfolder
// @String(label="open only files of type",choices={".r3d", ".ics", ".lif",".sld",".czi"}) infiletype
// @String(label="save the splitview movie as an additional file?",choices={"no", "yes"}) additionalfile
// @String(label="save as file type",choices={"ICS-1","ICS-2","OME-TIFF", "CellH5"}) outfiletype
// @String (label="auto processing ?",choices={"auto", "manuel"}) manuelc

// -------------------------------------------------------------------------------
// This is a batch-processing script, it opens Bio-formats supported files, allows rotation
// and exports the result in a Bio-formats-supported file and an .avi file.
// This script was written by Etienne Schmelzer with support of Gordian Born and Kai Schleicher.
// -------------------------------------------------------------------------------


// settings for moviemaker
// Colors of the Channels
//colors = newArray("Green", "Magenta", "Red");
colors = newArray("Green", "Magenta", "Magenta");

// Colors of the Timestamp (white)
setForegroundColor(255, 255, 255);

movie = "yes";
// Defines which channels are active in the composite (1 == active, 0== inactive).
composite_channels = "11"


// This paragraph checks, if a logfile already exists and deletes it
logfile= "V:/Python_Log.txt"
if (File.exists(logfile) == 1) {
	File.delete("V:/Python_Log.txt");
};

// check user selection and translate into proper file endings
if (outfiletype == "ICS-1") {
    tgt_suffix = ".ids";
} else if (outfiletype == "ICS-2") {
    tgt_suffix = ".ics";
} else if (outfiletype == "OME-TIFF") {
    tgt_suffix = ".ome.tif";
} else if (outfiletype == "CellH5") {
    tgt_suffix = ".ch5";
}


function getTimestamp() {
// generates a Timestamp, no arguments needed
	MonthNames = newArray("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
	DayNames = newArray("Sun", "Mon","Tue","Wed","Thu","Fri","Sat");
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	TimeString ="Date: "+DayNames[dayOfWeek]+" ";
	if (dayOfMonth<10) {TimeString = TimeString+"0";}
	TimeString = TimeString+dayOfMonth+"-"+MonthNames[month]+"-"+year+" Time: ";
	if (hour<10) {TimeString = TimeString+"0";}
	TimeString = TimeString+hour+":";
	if (minute<10) {TimeString = TimeString+"0";}
	TimeString = TimeString+minute+":";
	if (second<10) {TimeString = TimeString+"0";}
	TimeString = TimeString+second;
	//print(TimeString);
	return TimeString;
}



function moviemaker(title, outfile, manuelc, colors, composite_channels) {
	/*
	 * This function takes a Hyperstack and generates a Splitview image.
	 * Displaying the Composite image with the active channels defined in composite_channels
	 * and all the separate channels.
	 * title: title of the input file / getTitle() can be used instead
	 * outfile: path+filename of the desired output
	 * manuelc: if manuelc == "manuel", the User can manually:
	 * 		- crop,
	 * 		- set Thresholds
	 * 		- determine location of the Scale bar
	 * 	composite_channels: str "101" which channels are active in the composite: Channel1 and Channel3
	 */
	selectWindow(title);

	int = Stack.getFrameInterval();
	//print("The stack-frame interval is " + int +" seconds");
	run("Z Project...", "projection=[Max Intensity] all");
	rename("MAX_");
	selectWindow("MAX_");
	Stack.getDimensions(width, height, channels, slices, frames);
	for (i = 0; i < channels; i++) {
		//print("Channelcolor: " + colors[i]);
		Stack.setChannel(i+1);
		run("Enhance Contrast", "saturated=0.35");
		run(colors[i]);


	};
	Stack.setDisplayMode("composite");
	Stack.setActiveChannels(composite_channels);

	// if processing the data by hand -> the image can be cropped
	if (manuelc == "manuel") {
		skip=getBoolean("Do you want to crop?");
		if (skip==true) {
			waitForUser("Please select area");
			run("Duplicate...", "duplicate");
			print(title + " has been cropped");
			close("MAX_");
			selectWindow("MAX_-1");
			rename("MAX_");
		}

	}
	run("Duplicate...", "duplicate");
	title_duplicate=getTitle();

	selectWindow(title_duplicate);
	Stack.setDisplayMode("composite");
	Stack.setActiveChannels(composite_channels);


	selectWindow("MAX_");
	run("Split Channels");

	for (i = 0; i < channels; i++) {
		selectWindow("C"+i+1+"-MAX_");
		run("Invert", "stack");
		run("Enhance Contrast...", "saturated=0.35");
		run("Grays");
	}

	if (manuelc == "manuel") {
		waitForUser("please pick your brightness");
	}

	// flatten the images
	for (i = 0; i < channels; i++) {
		selectWindow("C"+i+1+"-MAX_");
		run("RGB Color");
	}


	selectWindow(title_duplicate);
	run("RGB Color", "frames");

	run("Combine...", "stack1=["+ title_duplicate+"] stack2=[C1-MAX_]");
	for (i = 2; i <= channels; i++) {
		image = "C"+i+"-MAX_";
		run("Combine...", "stack1=[Combined Stacks] stack2=[" +image + "]");
	}

	//z=getNumber("What is the Time Interval of"+title_max+" ?", int);
	z = int;

	run("Label...", "format=00:00:00 starting=0 interval="+z+" x=10 y=25 font=18");

	selectWindow("Combined Stacks");
	getDimensions(width, height, channels, slices, frames);
	makeRectangle((width-60), (height-30), 10, 10);


	if (manuelc == "manuel") {
		waitForUser("mark where to enter scale bar");
	}

	run("Scale Bar...", "width=5 height=4 font=14 color=White background=None location=[At Selection] overlay");

	if (manuelc == "manuel") {
		waitForUser("Press OK to save");
	}

	selectWindow("Combined Stacks");
	rename(outfile);
	print("Saving of " + outfile +".avi");
	run("AVI... ", "compression=JPEG frame=3 save=["+ outfile +".avi]");

}




function converter(infiletype, outfiletype, dir1, dir2, movie) {
// converts the files with the ending "infiletype" to the desired "outfiletype"
// dir1 is the directory for the incoming files
// dir2 is the targetdirectory
	list = getFileList(dir1);

	for (i=0; i<list.length; i++) {
	    // only open an image with the requested extension:
	    if(endsWith(list[i], infiletype)){
	    	print("Processing: " + list[i]);

	        incoming = dir1+File.separator+list[i];

	        //open the image at position i as a hyperstack using the bio-formats
	        //opens all images of a container file (e.g. *.lif, *.sld)
	       	run("Bio-Formats Importer", "open=[" + incoming + "] color_mode=Default open_all_series view=Hyperstack stack_order=XYCZT use_virtual_stack");


	    	for (k=1; k <= nImages; k++) {
	            selectImage(k);
	            title_o = getTitle();
	            title = replace(title_o,infiletype,"");
	            title = replace(title," ","_");

	            outFile = dir2 +File.separator+ title;

	            // plug in your analysis here!!

	            if (movie == "yes") {

	            	print("Generating an exciting splitview movie");
	            	print("Location: " + outFile);
	            	moviemaker(getTitle(), outFile, manuelc, colors, composite_channels);
	            }

	            if (additionalfile == "yes") {
	            	outfile = outFile+tgt_suffix;
	            	print("Saving the file:\n" + outfile);
	            	run("Bio-Formats Exporter", "save=[" + outfile + "]");
	            }

	    		close();
	    		close(title_o);

	            //break
	    	}

	        run("Close All");  // close all images to free the memory
	    }
	}

	print(" ");
	print("All done");
};



print("The script has been started at: " + getTimestamp());
if (subfolder == "Yes") {
	list = getFileList(dir0);
	for (i=0; i<list.length; i++) {
		dir1 = dir0 + File.separator + list[i];

		converter(infiletype, outfiletype, dir1, dir2, movie);

	};
}


if (subfolder == "No") {
	dir1 = dir0;

	converter(infiletype, outfiletype, dir1, dir2, movie);

}

// finalising the log and saving a txt file
// this txt file will fullfill the condition to autologout for the external python script

print("The script finished at: " + getTimestamp());
selectWindow("Log");
saveAs("Text", logfile);
