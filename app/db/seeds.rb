users = [
  { user_id: '6a731fbe-fe37-44af-8452-62387ae93da6', username: 'fuga', passwd: 'e6da8c345d56443958171fa36bf60140ec6aa724a8184b2b29d3004e9f390ccc', email: 'fuga@r0uei.dev' },
  { user_id: '8abc6c35-8c46-485b-bfc7-ad668f3d03b2', username: 'yu1hpa', passwd: 'd4fa46e80b7a532cdbd4ecc6e669cd37ccddf23f33abade2f7772e75473053d1', email: 'yu1hpa@r0uei.dev' }
]

users.each do |u|
  User.create(u)
end

yu1hpa_reports = [
  { user_id: '8abc6c35-8c46-485b-bfc7-ad668f3d03b2', report: '本報告書は、私たちのチームが行った研究の結果をまとめたものです。研究のテーマは、新型コロナウイルスの影響についてです。研究の結果、感染者数は急増していることが確認され、さらに深刻な状況が予想されます。対策として、増加する感染者数を抑えるために、居宅要請やイベントの中止、マスク着用などが提言されています。' },
  { user_id: '8abc6c35-8c46-485b-bfc7-ad668f3d03b2', report: 'The annual report shows a steady increase in profits and a growing customer base. Efforts to expand into new markets have been successful. The company is well-positioned for continued growth in the coming year.'},
  { user_id: '8abc6c35-8c46-485b-bfc7-ad668f3d03b2', report: '年度報告顯示利潤穩定增長，客戶群不斷擴大。拓展新市場的努力取得了成功。公司在未來一年具有良好發展潛力。'}
]

fuga_reports = [
  { user_id: '6a731fbe-fe37-44af-8452-62387ae93da6', report: 'The quarterly report showed a significant increase in sales for our e-commerce division. The implementation of new marketing strategies and partnerships have been successful in driving growth. We are also pleased to announce the expansion of our retail footprint with the opening of new stores in key locations.'},
  { user_id: '6a731fbe-fe37-44af-8452-62387ae93da6', report: '四半期報告は、当社のeコマース部門の売上が大幅に増加していることを示しています。新しいマーケティング戦略やパートナーシップの採用が成長を促進することに成功しました。また、新しい店舗の開設により、リテールフットプリントの拡大ができることを喜ばしく思います。'},
  { user_id: '6a731fbe-fe37-44af-8452-62387ae93da6', report: '本季度报告显示公司电商部门销售额大幅增长。新的营销策略和合作关系的实施取得了成功。公司在关键地点开设新店，将继续扩大零售业务。'}
]

reports = yu1hpa_reports + fuga_reports
reports.each do |r|
  Report.create(r)
end