<?php
	include 'securimage.php';
	
	$img = new securimage();
	
	$img->image_width = 250;
	$img->image_height = 99;
	$img->perturbation = 0.85;
	$img->num_lines = 12;
	$img->image_bg_color = new Securimage_Color("#F9FAFB");
	$img->image_type = SI_IMAGE_PNG;
	
	$img->show(); // alternate use:  $img->show('/path/to/background_image.jpg');
