#  GG Music

## Running the App

1. This app will not work on an emulator. A real device is required.
2. This app requires that the "iCloud Music Library" setting is enabled.

## Known Issues

1. After deleting a playlist in the Apple Music app, the playlist remains to be seen in the GGMusic app for up to 20 seconds. The reason for this is that creating and deleting playlists using the Apple Music API does not immediately create or delete it. This means that when a playlist is created, it may not be part of the get all playlists network request response for up to about 20 seconds. To circumvate this issue, GGMusic saves a local copy of the newly created playlist and only deletes it if it has truly been deleted in the Apple Music app after 20 seconds.
2. The same song will not appear in the same playlist more than once even if there are multiple copies of it added. 

## Limitations

1. This app will not work for users with an Apple Music subscription from family sharing. 
2. This app does not implement deleting playlists or tracks from a playlist because the 
    Apple Music API does not support it. See https://forums.developer.apple.com/thread/107807
3. This app will not show local music files.

