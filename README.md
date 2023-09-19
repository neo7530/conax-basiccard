Conax compatible smart card using BasicCard ZC5.x

burn .img file to basiccard with 

"BCLoad.exe card.img -P100 -ST"

Personalize Card with:

conax.exe --port COM1 --ppua 1234567890 --ppsa 123456 --pass test

put it in your CI and do an onboarding within CAS-System 

Update 20230919

- switch added for 64-Bit/48-Bit CW via access-criteria via lowest bit (bit 0)
	e.g: --access-criteria 00000001 = 48-Bit CW (reduced entropy)
	     --access-criteria 80000001 = 64-Bit CW (full entropy) (works mostly on softcam, real CI automaticly reduces the entropy to 48-Bit)