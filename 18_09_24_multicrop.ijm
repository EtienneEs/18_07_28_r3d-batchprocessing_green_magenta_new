// @int (label= "How many columns?") columns
// @int (label= "How many rows?") rows
// @File (label="destination directory",style="directory") dir2
// @String (label= "Save as filetype...", choices = {".ome.tif", ".tif", ".png"}) tgt_suffix


//--------------------------------------
// This FIJI script divides/crops the already open image into multiple "sub-" images.
// The user can define into how many rows and columns the image will be split,
// the final filetype and the directory where the files will be saved.
// This script has been written by Etienne Schmelzer for Benjamin Sellner.
// --------------------------------------

// the function takes the arguments dir2 -which corresponds the target directory
// for the "sub-images",the desired file-ending (tgt_suffix) as well as
// the amount of columns and rows which will divide the image.
function multicrop(dir2, tgt_suffix, columns, rows) {
	file = getTitle();
	filename = File.nameWithoutExtension;
	getDimensions(ox,oy,ch,slices,frames);
	waitForUser("This is alll for Beni!!")
	for (y = 0; y < columns; y++){
		for (x=0; x < rows; x++) {
			makeRectangle((ox/columns)*x, (oy/rows)*y, ox/columns, oy/rows);
			run("Duplicate...", "duplicate");
			newfilename = filename + x + "_" + y;
			print(newfilename);
			outFile = dir2 + File.separator + newfilename + tgt_suffix;
			print(outFile);
			run("Bio-Formats Exporter", "save=[" + outFile + "]");
			close();
		};
	};
};



multicrop(dir2, tgt_suffix, columns, rows);
