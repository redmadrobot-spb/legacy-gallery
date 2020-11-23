//
// GalleryMedia
// LegacyGallery
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import UIKit
import AVFoundation

public enum GalleryMedia {
    case image(Image)
    case video(Video)

    public typealias PreviewImageLoader = (_ size: CGSize, _ completion: @escaping (Result<UIImage, Error>) -> Void) -> Void
    public typealias ImageLoader = (_ completion: @escaping (Result<UIImage, Error>) -> Void) -> Void
    public typealias VideoLoader = (_ type: Video.LoadingType, _ completion: @escaping (Result<URL, Error>) -> Void) -> Void

    public struct Image {
        public var index: Int
        public var previewImage: UIImage?
        public var previewImageLoader: PreviewImageLoader?
        public var image: UIImage?
        public var imageLoader: ImageLoader?

        public init(
            index: Int = 0,
            previewImage: UIImage? = nil,
            previewImageLoader: PreviewImageLoader? = nil,
            image: UIImage? = nil,
            imageLoader: ImageLoader? = nil
        ) {
            self.index = index
            self.previewImage = previewImage
            self.previewImageLoader = previewImageLoader
            self.image = image
            self.imageLoader = imageLoader
        }
    }

    public struct Video {
        public enum LoadingType {
            case streaming
            case downloading
        }

        public var index: Int
        public var videoAsset: AVAsset?
        public var previewImage: UIImage?
        public var previewImageLoader: PreviewImageLoader?
        public var videoLoader: VideoLoader?

        public init(
            index: Int = 0,
            videoAsset: AVAsset? = nil,
            previewImage: UIImage? = nil,
            previewImageLoader: PreviewImageLoader? = nil,
            videoLoader: VideoLoader? = nil
        ) {
            self.index = index
            self.videoAsset = videoAsset
            self.previewImage = previewImage
            self.previewImageLoader = previewImageLoader
            self.videoLoader = videoLoader
        }
    }
}
