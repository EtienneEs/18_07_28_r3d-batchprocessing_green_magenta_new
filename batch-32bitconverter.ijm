// @File(label="source directory",style="directory") dir1
// @File(label="destination directory",style="directory") dir2
// @String(label="open only files of type",choices={".ids", ".r3d", ".mvd2",".lif",".sld",".czi"}) infiletype
// @String(label="save as file type",choices={"ICS-1","ICS-2","OME-TIFF", "CellH5"}) outfiletype
// @String(label="Autologout ?", choices= {"No", "Yes"}) autologout

// -------------------------------------------------------------------------------
// This is a batchprocessing script. It will process every image of a chosen folder
// with a chosen fileending. It will open only the first timepoint and convert this
// from 32bit to 16bit and save it as the chosen fileformat. 
// -------------------------------------------------------------------------------


setBatchMode(true);

// -------------------------------------------------------------------------------


// function bitConverter takes no arguments
// will analyse the currently selected Stack and identify the max intensity,
// based on the Stack maximum intensity value it will convert the Image to
// 16bitconvert the currently selected image
// this code has been generated by Kai Schleicher
function bitConverter() {
	//selectWindow(title);
	print("bitconversion starts");
	if(bitDepth()==32){
		Stack.getStatistics(voxelCount, mean, min, max, stdDev);
		print("max px value in the hyperstack= ", max);
		Stack.getDimensions(width, height, channels, slices, frames);

		// reset the scale to 0 and max in each channel before converting
		for (k=0; k<channels; k++) {
			Stack.setChannel(k+1);
			print("maximum pixel value used to scale to 16bit = ", max);
			setMinAndMax(0, max);
		}
		// convert to 16bit
		run("16-bit");
	}
}



// -------------------------------------------------------------------------------
// batchprocessing template, only plug in the function/ processing into the
// batchprocesser function.
// -------------------------------------------------------------------------------


// function targetsuffix, takes arguments outfiletype(str)
// will convert the outfiletype into a Bioformat exporter compatible fileending
// modified and adapted from Kai Schleicher
function targetsuffix(outfiletype) {
	if (outfiletype == "ICS-1") {
		tgt_suffix = ".ids";
	} else if (outfiletype == "ICS-2") {
		tgt_suffix = ".ics";
	} else if (outfiletype == "OME-TIFF") {
		tgt_suffix = ".ome.tif";
	} else if (outfiletype == "CellH5") {
		tgt_suffix = ".ch5";
	}
	return tgt_suffix;
}

// function getTimestamp() takes no arguments
// will return the actual time in a readable format as a string
// adapted and modified from imagej.nih.gov examples
function getTimestamp() {
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


// function batchprocesser takes arguments: infiletype, targetfileformat, sourcedirectory, targetdirectory
// the function will process the files which are present in the sourcedirectory, process them,
// according to the inserted functions/processes and save them in the specified targetfileformat
// this function has been adapted and modified from Kai Schleicher and imagej.net/BatchProcessing#Option_2_-_Script_Template
function batchprocesser(infiletype, tgt_suffix, dir1, dir2) {
	print("Processing Folder:" + dir1);
	list = getFileList(dir1);
	for (i=0; i<list.length; i++) {
		// only open an image with the requested extension:
		if(endsWith(list[i], infiletype)){
			print(list[i]);

			incoming = dir1 + File.separator + list[i];
			print("This is incoming" + incoming);
			//opens only timepoint1 no virtual stack
			run("Bio-Formats Importer", "open=[" + incoming + "] color_mode=Default open_all_series specify_range view=Hyperstack stack_order=XYCZT t_begin=1 t_end=1");

			// get image IDs of all open images:
			all = newArray(nImages);

			for (k=0; k < nImages; k++) {
					selectImage(k+1);
					all[k] = getImageID;
					title = getTitle();
					print("This is the title" + title);
					title = replace(title,infiletype,"");
					title = replace(title," ","_");
					print("saving file..."+ title);
					// -------------------- put in functions and processing below -------------------

					print("Your function is about to be executed");

					//desiredFunction
					bitConverter();

					// ------------------- now the files will be saved -------------------
					outFile = dir2 +File.separator+ title + tgt_suffix;
					print(outFile);
					run("Bio-Formats Exporter", "save=[" + outFile + "]");
					print("Done");
				}
				//break
				run("Close All");  // close all images to free the memory

			}
	//break
	}
}




print("The script has been started at: " + getTimestamp());

if (autologout == "Yes") {
	logfile= "V:/Python_Log.txt"
	if (File.exists(logfile) == 1) {
		File.delete("V:/Python_Log.txt");
	};
}

tgt_suffix = targetsuffix(outfiletype);

batchprocesser(infiletype, tgt_suffix, dir1, dir2);

print("The script has finished: " + getTimestamp());

if (autologout == "Yes") {
	selectWindow("Log");
	saveAs("Text", logfile);
}
