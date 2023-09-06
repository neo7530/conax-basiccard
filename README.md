Conax compatible smart card using BasicCard ZC5.x

burn .img file to basiccard with 

"BCLoad.exe card.img -P100 -ST"

Personalize Card with:

conax.exe --port COM1 --ppua 1234567890 --ppsa 123456 --pass test

put it in your CI and do an onboarding within CAS-System 