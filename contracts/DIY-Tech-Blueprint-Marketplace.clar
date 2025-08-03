(define-non-fungible-token blueprint uint)

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-authorized (err u101))
(define-constant err-blueprint-not-found (err u102))
(define-constant err-already-licensed (err u103))
(define-constant err-insufficient-payment (err u104))
(define-constant err-transfer-failed (err u105))
(define-constant err-mint-failed (err u106))
(define-constant err-no-license-to-review (err u112))
(define-constant err-already-reviewed (err u113))
(define-constant err-invalid-rating (err u114))

(define-data-var blueprint-id-nonce uint u1)
(define-data-var marketplace-fee-rate uint u250)

(define-map blueprints
  uint
  {
    creator: principal,
    title: (string-ascii 64),
    description: (string-ascii 256),
    category: (string-ascii 32),
    price: uint,
    license-type: (string-ascii 16),
    is-open-source: bool,
    version: uint,
    created-at: uint,
    updated-at: uint
  }
)

(define-map blueprint-versions
  {blueprint-id: uint, version: uint}
  {
    ipfs-hash: (string-ascii 64),
    changelog: (string-ascii 256),
    contributor: principal,
    timestamp: uint
  }
)

(define-map licenses
  {blueprint-id: uint, licensee: principal}
  {
    license-type: (string-ascii 16),
    purchased-at: uint,
    expires-at: (optional uint),
    is-active: bool
  }
)

(define-map contributors
  {blueprint-id: uint, contributor: principal}
  {
    contribution-count: uint,
    total-earnings: uint,
    share-percentage: uint
  }
)

(define-map creator-stats
  principal
  {
    blueprints-created: uint,
    total-sales: uint,
    reputation-score: uint
  }
)

(define-map dao-grants
  uint
  {
    blueprint-id: uint,
    recipient: principal,
    amount: uint,
    status: (string-ascii 16),
    awarded-at: uint
  }
)

(define-data-var grant-id-nonce uint u1)

(define-map blueprint-reviews
  {blueprint-id: uint, reviewer: principal}
  {
    rating: uint,
    review-text: (string-ascii 500),
    created-at: uint
  }
)

(define-map blueprint-ratings
  uint
  {
    total-rating: uint,
    review-count: uint,
    average-rating: uint
  }
)

(define-public (mint-blueprint 
  (title (string-ascii 64))
  (description (string-ascii 256))
  (category (string-ascii 32))
  (price uint)
  (license-type (string-ascii 16))
  (is-open-source bool)
  (ipfs-hash (string-ascii 64))
)
  (let
    (
      (blueprint-id (var-get blueprint-id-nonce))
      (current-time (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1))))
    )
    (asserts! (> (len title) u0) (err u107))
    (asserts! (> (len description) u0) (err u108))
    
    (try! (nft-mint? blueprint blueprint-id tx-sender))
    
    (map-set blueprints blueprint-id
      {
        creator: tx-sender,
        title: title,
        description: description,
        category: category,
        price: price,
        license-type: license-type,
        is-open-source: is-open-source,
        version: u1,
        created-at: current-time,
        updated-at: current-time
      }
    )
    
    (map-set blueprint-versions
      {blueprint-id: blueprint-id, version: u1}
      {
        ipfs-hash: ipfs-hash,
        changelog: "Initial version",
        contributor: tx-sender,
        timestamp: current-time
      }
    )
    
    (map-set creator-stats tx-sender
      (merge
        (default-to 
          {blueprints-created: u0, total-sales: u0, reputation-score: u0}
          (map-get? creator-stats tx-sender)
        )
        {blueprints-created: (+ (get blueprints-created (default-to {blueprints-created: u0, total-sales: u0, reputation-score: u0} (map-get? creator-stats tx-sender))) u1)}
      )
    )
    
    (var-set blueprint-id-nonce (+ blueprint-id u1))
    (ok blueprint-id)
  )
)

(define-public (purchase-license (blueprint-id uint))
  (let
    (
      (blueprint-data (unwrap! (map-get? blueprints blueprint-id) err-blueprint-not-found))
      (price (get price blueprint-data))
      (creator (get creator blueprint-data))
      (fee-amount (/ (* price (var-get marketplace-fee-rate)) u10000))
      (creator-amount (- price fee-amount))
      (current-time (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1))))
    )
    (asserts! (is-none (map-get? licenses {blueprint-id: blueprint-id, licensee: tx-sender})) err-already-licensed)
    (asserts! (> price u0) err-insufficient-payment)
    
    (try! (stx-transfer? creator-amount tx-sender creator))
    (try! (stx-transfer? fee-amount tx-sender contract-owner))
    
    (map-set licenses
      {blueprint-id: blueprint-id, licensee: tx-sender}
      {
        license-type: (get license-type blueprint-data),
        purchased-at: current-time,
        expires-at: none,
        is-active: true
      }
    )
    
    (map-set creator-stats creator
      (merge
        (default-to 
          {blueprints-created: u0, total-sales: u0, reputation-score: u0}
          (map-get? creator-stats creator)
        )
        {
          total-sales: (+ (get total-sales (default-to {blueprints-created: u0, total-sales: u0, reputation-score: u0} (map-get? creator-stats creator))) creator-amount),
          reputation-score: (+ (get reputation-score (default-to {blueprints-created: u0, total-sales: u0, reputation-score: u0} (map-get? creator-stats creator))) u1)
        }
      )
    )
    
    (ok true)
  )
)

(define-public (add-version 
  (blueprint-id uint)
  (ipfs-hash (string-ascii 64))
  (changelog (string-ascii 256))
)
  (let
    (
      (blueprint-data (unwrap! (map-get? blueprints blueprint-id) err-blueprint-not-found))
      (current-version (get version blueprint-data))
      (new-version (+ current-version u1))
      (current-time (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1))))
    )
    (asserts! (is-contributor-or-creator blueprint-id tx-sender) err-not-authorized)
    
    (map-set blueprint-versions
      {blueprint-id: blueprint-id, version: new-version}
      {
        ipfs-hash: ipfs-hash,
        changelog: changelog,
        contributor: tx-sender,
        timestamp: current-time
      }
    )
    
    (map-set blueprints blueprint-id
      (merge blueprint-data {version: new-version, updated-at: current-time})
    )
    
    (map-set contributors
      {blueprint-id: blueprint-id, contributor: tx-sender}
      (merge
        (default-to 
          {contribution-count: u0, total-earnings: u0, share-percentage: u0}
          (map-get? contributors {blueprint-id: blueprint-id, contributor: tx-sender})
        )
        {contribution-count: (+ (get contribution-count (default-to {contribution-count: u0, total-earnings: u0, share-percentage: u0} (map-get? contributors {blueprint-id: blueprint-id, contributor: tx-sender}))) u1)}
      )
    )
    
    (ok new-version)
  )
)

(define-public (add-contributor (blueprint-id uint) (contributor principal) (share-percentage uint))
  (let
    (
      (blueprint-data (unwrap! (map-get? blueprints blueprint-id) err-blueprint-not-found))
    )
    (asserts! (is-eq tx-sender (get creator blueprint-data)) err-not-authorized)
    (asserts! (<= share-percentage u100) (err u109))
    
    (map-set contributors
      {blueprint-id: blueprint-id, contributor: contributor}
      {
        contribution-count: u0,
        total-earnings: u0,
        share-percentage: share-percentage
      }
    )
    
    (ok true)
  )
)

(define-public (award-dao-grant (blueprint-id uint) (amount uint))
  (let
    (
      (blueprint-data (unwrap! (map-get? blueprints blueprint-id) err-blueprint-not-found))
      (grant-id (var-get grant-id-nonce))
      (current-time (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1))))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (get is-open-source blueprint-data) (err u110))
    
    (try! (stx-transfer? amount contract-owner (get creator blueprint-data)))
    
    (map-set dao-grants grant-id
      {
        blueprint-id: blueprint-id,
        recipient: (get creator blueprint-data),
        amount: amount,
        status: "awarded",
        awarded-at: current-time
      }
    )
    
    (var-set grant-id-nonce (+ grant-id u1))
    (ok grant-id)
  )
)

(define-public (update-marketplace-fee (new-fee-rate uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (<= new-fee-rate u1000) (err u111))
    (var-set marketplace-fee-rate new-fee-rate)
    (ok true)
  )
)

(define-public (submit-review (blueprint-id uint) (rating uint) (review-text (string-ascii 500)))
  (let
    (
      (current-time (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1))))
      (existing-review (map-get? blueprint-reviews {blueprint-id: blueprint-id, reviewer: tx-sender}))
      (current-ratings (default-to {total-rating: u0, review-count: u0, average-rating: u0} (map-get? blueprint-ratings blueprint-id)))
    )
    (asserts! (has-license blueprint-id tx-sender) err-no-license-to-review)
    (asserts! (is-none existing-review) err-already-reviewed)
    (asserts! (and (>= rating u1) (<= rating u5)) err-invalid-rating)
    (asserts! (> (len review-text) u0) err-invalid-rating)
    
    (map-set blueprint-reviews
      {blueprint-id: blueprint-id, reviewer: tx-sender}
      {
        rating: rating,
        review-text: review-text,
        created-at: current-time
      }
    )
    
    (let
      (
        (new-total-rating (+ (get total-rating current-ratings) rating))
        (new-review-count (+ (get review-count current-ratings) u1))
        (new-average-rating (/ new-total-rating new-review-count))
      )
      (map-set blueprint-ratings blueprint-id
        {
          total-rating: new-total-rating,
          review-count: new-review-count,
          average-rating: new-average-rating
        }
      )
    )
    
    (ok true)
  )
)

(define-read-only (get-blueprint (blueprint-id uint))
  (map-get? blueprints blueprint-id)
)

(define-read-only (get-blueprint-version (blueprint-id uint) (version uint))
  (map-get? blueprint-versions {blueprint-id: blueprint-id, version: version})
)

(define-read-only (get-license (blueprint-id uint) (licensee principal))
  (map-get? licenses {blueprint-id: blueprint-id, licensee: licensee})
)

(define-read-only (has-license (blueprint-id uint) (licensee principal))
  (match (map-get? licenses {blueprint-id: blueprint-id, licensee: licensee})
    license (get is-active license)
    false
  )
)

(define-read-only (get-contributor (blueprint-id uint) (contributor principal))
  (map-get? contributors {blueprint-id: blueprint-id, contributor: contributor})
)

(define-read-only (get-creator-stats (creator principal))
  (map-get? creator-stats creator)
)

(define-read-only (get-dao-grant (grant-id uint))
  (map-get? dao-grants grant-id)
)

(define-read-only (get-marketplace-fee-rate)
  (var-get marketplace-fee-rate)
)

(define-read-only (get-next-blueprint-id)
  (var-get blueprint-id-nonce)
)

(define-read-only (get-blueprint-review (blueprint-id uint) (reviewer principal))
  (map-get? blueprint-reviews {blueprint-id: blueprint-id, reviewer: reviewer})
)

(define-read-only (get-blueprint-rating (blueprint-id uint))
  (map-get? blueprint-ratings blueprint-id)
)

(define-read-only (get-blueprint-average-rating (blueprint-id uint))
  (match (map-get? blueprint-ratings blueprint-id)
    ratings (some (get average-rating ratings))
    none
  )
)

(define-private (is-contributor-or-creator (blueprint-id uint) (user principal))
  (let
    (
      (blueprint-data (unwrap! (map-get? blueprints blueprint-id) false))
    )
    (or
      (is-eq user (get creator blueprint-data))
      (is-some (map-get? contributors {blueprint-id: blueprint-id, contributor: user}))
    )
  )
)
