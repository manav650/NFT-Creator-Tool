<?php require("script.php") ?>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="description" content="How to store form data in a json file with php">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<link rel="stylesheet" href="styles.css">
	<script src="https://cdn.jsdelivr.net/npm/web3@latest/dist/web3.min.js"></script>
	<title>Storing messages in a json file with PHP</title>
</head>
<body>

	<h1>Create your own NFT contract!</h1>

	<p style="margin: 15px; color: black;">Wallet Address - <span id="wallet-address"></span></p>
  <!-- <p>Wallet Address - <span id="wallet-address"></span></p> -->
  <!-- <button id="btn">Connect to metamask</button> -->

	<!-- <input type="button" id='script' name="scriptbutton" value=" Run Script " onclick="goPython()">

    <script src="http://code.jquery.com/jquery-3.3.1.min.js" integrity="sha256-FgpCb/KJQlLNfOu91ta32o/NMZxltwRo8QtmkMRdAu8=" crossorigin="anonymous"></script>

    <script>
        function goPython(){
            $.ajax({
              url: "./initiate.py",
             context: document.body
            }).done(function() {
             alert('finished python script');;
            });
        }
    </script> -->

	<!-- Let's begin with our form element -->
	<form action="success.html" method="post">

		<input type="hidden" id="btnClickedValue" name="btnClickedValue" value="" />
		
		<h3>Enter the form details</h3>
		<label>Enter name of contract</label>
		<input type="text" name="name" placeholder="crypto_kitties">

		<label>Enter the symbol</label>
		<input type="text" name="symbol" placeholder="NFT">

		<label>Enter the metadata</label>
		<input type="text" name="metadata" placeholder="http://your_metadata_url.com">

		<label>Enter the mint price</label>
		<input type="number" name="mint_price" step="any" placeholder="0.02">

		<label>Enter the total supply</label>
		<input type="number" name="total_supply" placeholder="200">

		<label class="checkbox-inline">
      <input style="margin: 15px;" name='mark_feat' type="checkbox">Include the marketplace features
    </label>

		<div class="mark_feat" style="margin: auto;">
			<li><b>Offer</b></li>  
			<li><b>Bid</b></li>  
			<li><b>Buy</b></li>  
			<li><b>AcceptBid</b></li>
		</div>

		<br/>

		<input type="submit" name="submit" placeholder="Generate Contract">

		<p class="error"><?php echo @$error; ?></p>
		<p class="success"><?php echo @$success; ?></p>
	</form>


	<script type="text/javascript">
		let connect_metamask = (async () => {
			
			if(window.ethereum) {
				var account = null;
				await window.ethereum.enable();
				await window.ethereum.send('eth_requestAccounts');
				window.web3 = new Web3(window.ethereum);
		
				var accounts = await web3.eth.getAccounts();
				account = accounts[0];
				document.getElementById('wallet-address').textContent = account;
				document.getElementById("btnClickedValue").value = account;

			}
			else if (window.web3) {
   			window.web3 = new Web3(web3.currentProvider);
			}
			// Non-dapp browsers...
			else {
				console.log("Non-Ethereum browser detected. You should consider trying MetaMask!");
			}
		});
		connect_metamask()
		const account = document.getElementById('wallet-address').textContent;

	</script>

	
</body>
</html>