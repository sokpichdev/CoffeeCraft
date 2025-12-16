//
//  GenericInfiniteCarousel.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/16/25.
//
import UIKit
import SwiftUI

// MARK: - 1. The Generic UIViewRepresentable

struct GenericInfiniteCarousel<Content: View, T: Hashable>: UIViewRepresentable {
    // 1. Data: The items that drive the carousel
    let items: [T]
    
    // 2. Configuration: Carousel size
    let height: CGFloat
    let viewWidth: CGFloat
    
    // 3. State: The real index being viewed
    @Binding var currentIndex: Int
    
    // 4. Content Builder: The generic view to display for each item
    @ViewBuilder let content: (T) -> Content

    private let cellIdentifier = "HostingCell"

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        
        // Register the custom cell that hosts SwiftUI views
        collectionView.register(
            HostingCell<Content, T>.self,
            forCellWithReuseIdentifier: cellIdentifier
        )

        collectionView.dataSource = context.coordinator
        collectionView.delegate = context.coordinator
        
        context.coordinator.collectionView = collectionView

        // Initial scroll to start at the first item of the second loop
        DispatchQueue.main.async {
            let initialIndex = self.items.count
            collectionView.scrollToItem(
                at: IndexPath(item: initialIndex, section: 0),
                at: .centeredHorizontally,
                animated: false
            )
            // Update the bound index state
            context.coordinator.parent.currentIndex = initialIndex % self.items.count
        }

        return collectionView
    }

    func updateUIView(_ uiView: UICollectionView, context: Context) {}

    // MARK: - Coordinator (Handles UICollectionView Logic)
    class Coordinator: NSObject,
                       UICollectionViewDataSource,
                       UICollectionViewDelegateFlowLayout,
                       UIScrollViewDelegate {

        let parent: GenericInfiniteCarousel<Content, T>
        var timer: Timer?

        weak var collectionView: UICollectionView?
        
        // We will repeat the array 3 times for buffering
        private var loopCount: Int { 3 }

        init(parent: GenericInfiniteCarousel<Content, T>) {
            self.parent = parent
            super.init()
            startAutoScroll()
        }

        // MARK: DataSource
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return parent.items.count * loopCount
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: parent.cellIdentifier,
                for: indexPath
            ) as! HostingCell<Content, T>

            let realIndex = indexPath.item % parent.items.count
            let item = parent.items[realIndex]

            // Inject the SwiftUI view into the cell
            cell.configure(
                with: parent.content(item), // Pass the generic Content view
                size: CGSize(width: parent.viewWidth, height: parent.height),
                item: item,
                parent: self.parent // Pass parent for context
            )
            return cell
        }

        // MARK: Layout
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: collectionView.bounds.width, height: parent.height)
        }

        // MARK: Infinite Logic
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            adjustIfNeeded(scrollView)
        }

        func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
            adjustIfNeeded(scrollView)
        }

        private func adjustIfNeeded(_ scrollView: UIScrollView) {
            let pageWidth = scrollView.bounds.width
            let page = Int(round(scrollView.contentOffset.x / pageWidth))
            let itemCount = parent.items.count
            
            // Update the real index binding
            parent.currentIndex = page % itemCount

            // Snap forward: If we pass the end of the second loop (index 2*N), snap back to the start of the second loop (index N)
            if page >= itemCount * 2 {
                let resetIndex = page - itemCount
                scrollView.setContentOffset(
                    CGPoint(x: CGFloat(resetIndex) * pageWidth, y: 0),
                    animated: false
                )
            }
            // Snap backward: If we scroll before the start of the second loop (index N), snap forward to the end of the second loop (index 2N)
            else if page < itemCount {
                 let resetIndex = page + itemCount
                scrollView.setContentOffset(
                    CGPoint(x: CGFloat(resetIndex) * pageWidth, y: 0),
                    animated: false
                )
            }
        }
        // MARK: Auto Scroll

        func startAutoScroll() {
            // Invalidate existing timer if any

            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
                guard let self = self, let cv = self.collectionView else { return }
                
                // Calculate the next page index
                let currentPage = Int(round(cv.contentOffset.x / cv.bounds.width))
                let nextPage = currentPage + 1

                cv.setContentOffset(
                    CGPoint(x: CGFloat(nextPage) * cv.bounds.width, y: 0),
                    animated: true
                )
                // AdjustIfNeeded will be called when animation finishes
            }
        }
    }
}

// MARK: - 2. UICollectionViewCell to Host SwiftUI View

final class HostingCell<Content: View, T: Hashable>: UICollectionViewCell {
    private var hostingController: UIHostingController<Content>?
    private var currentItem: T?

    func configure(with view: Content, size: CGSize, item: T, parent: GenericInfiniteCarousel<Content, T>) {
        // This cleanup is still necessary for reuse
        hostingController?.view.removeFromSuperview()
        
        let controller = UIHostingController(rootView: view)
        contentView.addSubview(controller.view)
        controller.view.backgroundColor = .clear
        
        // Set constraints to fill the cell
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            controller.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
        
        hostingController = controller
        currentItem = item // Still track for debugging, but not for configuration check
    }
}
