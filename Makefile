SDK_HOME = /Applications/Adobe\ Flash\ Builder\ 4.7/sdks/4.6.0/

SOURCE_FILES = \
	mixpanel-as3-lib/src/com/adobe/serialization/json/JSON.as \
	mixpanel-as3-lib/src/com/adobe/serialization/json/JSONDecoder.as \
	mixpanel-as3-lib/src/com/adobe/serialization/json/JSONEncoder.as \
	mixpanel-as3-lib/src/com/adobe/serialization/json/JSONParseError.as \
	mixpanel-as3-lib/src/com/adobe/serialization/json/JSONToken.as \
	mixpanel-as3-lib/src/com/adobe/serialization/json/JSONTokenizer.as \
	mixpanel-as3-lib/src/com/adobe/serialization/json/JSONTokenType.as \
	mixpanel-as3-lib/src/com/mixpanel/Base64Encoder.as \
	mixpanel-as3-lib/src/com/mixpanel/CookieBackend.as \
	mixpanel-as3-lib/src/com/mixpanel/IStorageBackend.as \
	mixpanel-as3-lib/src/com/mixpanel/Mixpanel.as \
	mixpanel-as3-lib/src/com/mixpanel/NonPersistentBackend.as \
	mixpanel-as3-lib/src/com/mixpanel/SharedObjectBackend.as \
	mixpanel-as3-lib/src/com/mixpanel/Storage.as \
	mixpanel-as3-lib/src/com/mixpanel/Util.as

# perl -pe 's[mixpanel-as3-lib/src/][];s[/][.]g;s[\.as][]'
CLASSES = \
	com.adobe.serialization.json.JSON \
	com.adobe.serialization.json.JSONDecoder \
	com.adobe.serialization.json.JSONEncoder \
	com.adobe.serialization.json.JSONParseError \
	com.adobe.serialization.json.JSONToken \
	com.adobe.serialization.json.JSONTokenizer \
	com.adobe.serialization.json.JSONTokenType \
	com.mixpanel.Base64Encoder \
	com.mixpanel.CookieBackend \
	com.mixpanel.IStorageBackend \
	com.mixpanel.Mixpanel \
	com.mixpanel.NonPersistentBackend \
	com.mixpanel.SharedObjectBackend \
	com.mixpanel.Storage \
	com.mixpanel.Util


MAIN_SOURCE = mixpanel-as3-lib/src/com/mixpanel/Mixpanel.as

LIBRARY = bin/mixpanel-as3-lib.swc

TESTING_LIBRARY = mixpanel-as3-test/libs/mixpanel-as3-lib.swc

.PHONY : clean docs release build

$(TESTING_LIBRARY): $(LIBRARY)
	cp $(LIBRARY) $(TESTING_LIBRARY)

$(LIBRARY): $(SOURCE_FILES) bin
	$(SDK_HOME)/bin/compc \
		-source-path ./mixpanel-as3-lib/src/ \
		-include-classes $(CLASSES) \
		-output $(LIBRARY)

build: $(LIBRARY)

docs: $(MAIN_SOURCE)
	$(SDK_HOME)/bin/asdoc \
		-source-path ./mixpanel-as3-lib/src/ \
		-doc-sources $(MAIN_SOURCE) \
		-output ./mixpanel-as3-lib/docs \
		-main-title "Mixpanel AS3 Library" \
		-window-title "Mixpanel AS3 Library"

clean:
	-rm $(TESTING_LIBRARY)
	-rm $(LIBRARY)
	-rm -r bin

bin:
	mkdir bin

release:
	git checkout gh-pages
	git reset --hard HEAD
	git merge master
	make docs
	git commit -am "Updated Docs; Latest Release"
