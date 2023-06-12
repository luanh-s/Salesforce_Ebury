sfdx force:org:create -f config\project-scratch-def.json -a Ebury_Scratch
sfdx force:source:push -u Ebury_Scratch
sfdx force:org:open -p lightning/n/BookedTrades -u Ebury_Scratch