include windows/key.properties

windows:
	dart run msix:create --certificate-password "$(certificatePassword)" --certificate-path "$(certificatePath)" --version $(version)

android:
	flutter build apk --release --build-name $(version) --build-number $(code)
	flutter build appbundle --release --build-name $(version) --build-number $(code)

.PHONY: windows android