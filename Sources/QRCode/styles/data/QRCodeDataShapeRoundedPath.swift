//
//  QRCodeDataShapeRoundedPath.swift
//
//  Created by Darren Ford on 17/11/21.
//  Copyright © 2021 Darren Ford. All rights reserved.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import CoreGraphics
import Foundation

public extension QRCode.DataShape {
	@objc(QRCodeDataShapeRoundedPath) class RoundedPath: NSObject, QRCodeDataShapeHandler {
		public var name: String = "RoundedPath"

		static let DefaultSize   = CGSize(width: 10, height: 10)
		static let DefaultRect   = CGRect(origin: .zero, size: DefaultSize)
		static let DefaultRadius = CGSize(width: 3, height: 3)

		public func copyShape() -> QRCodeDataShapeHandler {
			RoundedPath()
		}

		static let templateCircle: CGPath = {
			CGPath(
				roundedRect: RoundedPath.DefaultRect,
				cornerWidth: DefaultRadius.width, cornerHeight: DefaultRadius.height,
				transform: nil)
		}()

		static let templateSquare: CGPath = {
			CGPath(rect: RoundedPath.DefaultRect, transform: nil)
		}()

		static let templateRoundTop: CGPath = {
			CGPath.RoundedRect(rect: RoundedPath.DefaultRect,
								  topLeftRadius: RoundedPath.DefaultRadius,
								  topRightRadius: RoundedPath.DefaultRadius)
		}()
		static let templateRoundRight: CGPath = {
			CGPath.RoundedRect(rect: RoundedPath.DefaultRect,
								  topRightRadius: RoundedPath.DefaultRadius,
								  bottomRightRadius: RoundedPath.DefaultRadius)
		}()
		static let templateRoundBottom: CGPath = {
			CGPath.RoundedRect(rect: RoundedPath.DefaultRect,
								  bottomLeftRadius: RoundedPath.DefaultRadius,
								  bottomRightRadius: RoundedPath.DefaultRadius)
		}()

		static let templateRoundLeft: CGPath = {
			CGPath.RoundedRect(rect: RoundedPath.DefaultRect,
								  topLeftRadius: RoundedPath.DefaultRadius,
								  bottomLeftRadius: RoundedPath.DefaultRadius)
		}()

		static let templateBottomRight: CGPath = {
			CGPath.RoundedRect(rect: RoundedPath.DefaultRect,
								  bottomRightRadius: RoundedPath.DefaultRadius)
		}()

		static let templateTopRight: CGPath = {
			CGPath.RoundedRect(rect: RoundedPath.DefaultRect,
								  topRightRadius: RoundedPath.DefaultRadius)
		}()

		static let templateTopLeft: CGPath = {
			CGPath.RoundedRect(rect: RoundedPath.DefaultRect,
								  topLeftRadius: RoundedPath.DefaultRadius)
		}()

		static let templateBottomLeft: CGPath = {
			CGPath.RoundedRect(rect: RoundedPath.DefaultRect,
								  bottomLeftRadius: RoundedPath.DefaultRadius)
		}()

		public func onPath(size: CGSize, data: QRCode) -> CGPath {
			return self.generatePath(size: size, data: data, isOn: true)
		}

		public func offPath(size: CGSize, data: QRCode) -> CGPath {
			return self.generatePath(size: size, data: data, isOn: false)
		}
	}
}

extension QRCode.DataShape.RoundedPath {
	private func generatePath(size: CGSize, data: QRCode, isOn: Bool) -> CGPath {

		let dx = size.width / CGFloat(data.pixelSize)
		let dy = size.height / CGFloat(data.pixelSize)
		let dm = min(dx, dy)

		// The scale required to convert our template paths to output path size
		let w = QRCode.DataShape.RoundedPath.DefaultSize.width
		let scaleTransform = CGAffineTransform(scaleX: dm / w, y: dm / w)

		let xoff = (size.width - (CGFloat(data.pixelSize) * dm)) / 2.0
		let yoff = (size.height - (CGFloat(data.pixelSize) * dm)) / 2.0

		let path = CGMutablePath()

		for row in 1 ..< data.pixelSize - 1 {
			for col in 1 ..< data.pixelSize - 1 {

				guard
					data.current[row, col] == isOn,
					data.isEyePixel(row, col) == false
				else {
					continue
				}

				let hasLeft   = data.current[row, col - 1]
				let hasRight  = data.current[row, col + 1]
				let hasTop    = data.current[row - 1, col]
				let hasBottom = data.current[row + 1, col]

				let translate = CGAffineTransform(translationX: CGFloat(col)*dm + xoff, y: CGFloat(row)*dm + yoff)

				if !hasLeft, !hasRight, !hasTop, !hasBottom {
					path.addPath(
						QRCode.DataShape.RoundedPath.templateCircle,
						transform: scaleTransform.concatenating(translate)
					)
				}
				else if hasLeft, !hasRight, !hasTop, !hasBottom {
					path.addPath(
						QRCode.DataShape.RoundedPath.templateRoundRight,
						transform: scaleTransform.concatenating(translate)
					)
				}
				else if !hasLeft, hasRight, !hasTop, !hasBottom {
					path.addPath(
						QRCode.DataShape.RoundedPath.templateRoundLeft,
						transform: scaleTransform.concatenating(translate)
					)
				}
				else if !hasLeft, !hasRight, hasTop, !hasBottom {
					path.addPath(
						QRCode.DataShape.RoundedPath.templateRoundBottom,
						transform: scaleTransform.concatenating(translate)
					)
				}
				else if !hasLeft, !hasRight, !hasTop, hasBottom {
					path.addPath(
						QRCode.DataShape.RoundedPath.templateRoundTop,
						transform: scaleTransform.concatenating(translate)
					)
				}

				else if hasLeft, hasTop, !hasRight, !hasBottom {
					path.addPath(
						QRCode.DataShape.RoundedPath.templateBottomRight,
						transform: scaleTransform.concatenating(translate)
					)
				}
				else if !hasLeft, hasTop, hasRight, !hasBottom {
					path.addPath(
						QRCode.DataShape.RoundedPath.templateBottomLeft,
						transform: scaleTransform.concatenating(translate)
					)
				}
				else if hasLeft, !hasTop, !hasRight, hasBottom {
					path.addPath(
						QRCode.DataShape.RoundedPath.templateTopRight,
						transform: scaleTransform.concatenating(translate)
					)
				}
				else if !hasLeft, !hasTop, hasRight, hasBottom {
					path.addPath(
						QRCode.DataShape.RoundedPath.templateTopLeft,
						transform: scaleTransform.concatenating(translate)
					)
				}

				else {
					path.addPath(
						QRCode.DataShape.RoundedPath.templateSquare,
						transform: scaleTransform.concatenating(translate)
					)
				}
			}
		}
		return path
	}

}
