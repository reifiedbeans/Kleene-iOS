#  Essentials

This framework is meant for code that is shared amonst other frameworks. For example, both the `AppleMusic` and `Kleene` targets need `HTTP`, `Handler`, and `URL` functionality. Therefore, those shared resources should go in here and be imported as `Essentials` by any target that needs them.
