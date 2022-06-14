# Salesforce_Ebury

## Instructions:

To run this Application properly, clone this repository, and open it with VSCode.

You will need a valid Salesforce Organization with Dev Hub Enabled.

Then, just copy/paste these 3 commands in your terminal at once, and run, and it will automatically create your scratch org, push all needed code, and open the application.

> sfdx force:org:create -f config\project-scratch-def.json -a Ebury_Scratch

> sfdx force:source:push -u Ebury_Scratch

> sfdx force:org:open -p lightning/n/BookedTrades -u Ebury_Scratch

PS: I've done a few more things than what was asked. For better project, I've changed the "New" button of the Custom object, to redirect to the create new trade view.

I also fulfilled REQ1 with 2 different ways. One was the Standard Object table, and another with a custom LWC. Feel free to choose witchever suits your needs.