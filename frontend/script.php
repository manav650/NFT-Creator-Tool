<?php



	// First of all we have to check if the form is submitted via the POST
	// method.
	if(isset($_POST['submit'])){
		// If the form is submitted we are gonna create a new associative array
		// to hold the values we will store.
		if(isset($_POST['mark_feat'])) $_markF = 1;
		else $_markF = 0;

		$new_message = array(
			"address" => $_POST['btnClickedValue'],
			"name" => $_POST['name'],
			"symbol" => $_POST['symbol'],
			"metadata" => $_POST['metadata'],
			"mint_price" => $_POST['mint_price'],
			"total_supply" => $_POST['total_supply'],
			"mark_feat" => $_markF
		);
		
		file_put_contents("messages.json", "");


		if(filesize("messages.json") == 0){
			
			$first_record = $new_message;
		
			$data_to_save = $first_record; 
		}

		// Now our last step is to store the data to the file (messages.json).
		if(!file_put_contents("messages.json", json_encode($data_to_save, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE), LOCK_EX)){
			// if something went wrong, we are showing an error message.
			$error = "Error storing message, please try again";
		}else{
			// and if everything went ok, we show a success message.
			$success =  "Details stored successfully";
		}
	}

?>
