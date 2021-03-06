require_relative '../rails_helper'

RSpec.describe API::Ver1::Poker_hands, type: :request do

  describe 'POST /api/v1/poker_hands' do

    <<-NOTE
             ## 正常に入力される場合
             ## 正常に入力されない場合
                ## APIのvaliadtionではじかれるケース
                ## Common_validationにはじかれるエラーが混在しているケース
    NOTE

    # 正常に入力される場合 #######################################################################################################################################################################################

    context '値が正常に入力される' do
      before do
        request       = "{\"cards\":
                                     [
                                       \"S9 S10 S11 S12 S13\",
                                       \"D9 S10 S11 S12 S13\",
                                       \"S8 S10 S11 S12 S13\",
                                       \"S12 S13 D13 H13 C13\",
                                       \"S12 D12 S13 D13 H13\",
                                       \"S11 S12 S13 D13 H13\",
                                       \"S11 S12 D12 S13 D13\",
                                       \"S10 S11 S12 S13 D13\",
                                       \"D1 H5 S12 H11 C8\"
                                      ]
                          }"

        post '/api/v1/poker_hands', params: request
        @json          = JSON.parse(response.body)
        @expected_json = {"result" => [
                                        {"card"=>"S9 S10 S11 S12 S13", "hand"=>"ストレートフラッシュ", "best"=>"true"},
                                        {"card"=>"D9 S10 S11 S12 S13", "hand"=>"ストレート", "best"=>"false"},
                                        {"card"=>"S8 S10 S11 S12 S13", "hand"=>"フラッシュ", "best"=>"false"},
                                        {"card"=>"S12 S13 D13 H13 C13", "hand"=>"フォー・オブ・ア・カインド", "best"=>"false"},
                                        {"card"=>"S12 D12 S13 D13 H13", "hand"=>"フルハウス", "best"=>"false"},
                                        {"card"=>"S11 S12 S13 D13 H13", "hand"=>"スリー・オブ・ア・カインド", "best"=>"false"},
                                        {"card"=>"S11 S12 D12 S13 D13", "hand"=>"ツーペア", "best"=>"false"},
                                        {"card"=>"S10 S11 S12 S13 D13", "hand"=>"ワンペア", "best"=>"false"},
                                        {"card"=>"D1 H5 S12 H11 C8", "hand"=>"ハイカード", "best"=>"false"}
                                       ]
                          }
      end

        it 'リクエストが201 Created となること' do
          expect(response).to be_success
          expect(response.status).to eq(201)
        end
        it '期待した JSON を返すこと' do
          expect(@json).to eq @expected_json
        end
    end


    # 正常に入力されない場合 ###############################################################################################################################################################################################

    # APIのValiadtionではじかれるケース #######################################################################################################################################################################################


    context '未入力の場合' do
      before do
        request       = "{}"
        post '/api/v1/poker_hands', params: request
        @json          = JSON.parse(response.body)
        @expected_json = {"error" =>{"msg"=>"不正なリクエストです。"}}
      end

      it 'リクエストが500 InternalServerErrorとなること' do
        expect(response.status).to eq(500)
      end
      it '期待したエラーメッセージを返すこと' do
        expect(@json).to eq @expected_json
      end
    end

    context 'cardsと入力されない場合' do
      before do
        request       = "{\"card\":
                                    [
                                     \"S9 S10 S11 S12 S13\"
                                    ]
                          }"

        post '/api/v1/poker_hands', params: request
        @json          = JSON.parse(response.body)
        @expected_json = {"error" =>{"msg"=>"不正なリクエストです。"}}
      end

      it 'リクエストが500 InternalServerErrorとなること' do
        expect(response.status).to eq(500)
      end
      it '期待したエラーメッセージを返すこと' do
        expect(@json).to eq @expected_json
      end
    end


    context '配列の要素がない場合' do
      before do
        request       = "{\"cards\":
                                    [
                                    ]
                          }"

        post '/api/v1/poker_hands', params: request
        @json          = JSON.parse(response.body)
        @expected_json = {"error" =>{"msg"=>"不正なリクエストです。"}}
      end

      it 'リクエストが500 InternalServerErrorとなること' do
        expect(response.status).to eq(500)
      end
      it '期待したエラーメッセージを返すこと' do
        expect(@json).to eq @expected_json
      end
    end


    # Common_Validator 1 にはじかれるケース #######################################################################################################################################################################################

    context 'Common_validation 1 にはじかれる（要素が５つない）' do
      before do
        request       = "{\"cards\":
                                     [
                                      \"S9 S11 S12 S13\",
                                      \"S8 S9 S10 S11 S12 S13\",
                                      \"S9S10 S11 S12 S13\"
                                     ]
                          }"

        post '/api/v1/poker_hands', params: request
        @json          = JSON.parse(response.body)
        @expected_json = {"error" => [
                                       {"card"=>"S9 S11 S12 S13", "msg"=>"5つのカード指定文字を半角スペース区切りで入力してください。"},
                                       {"card"=>"S8 S9 S10 S11 S12 S13", "msg"=>"5つのカード指定文字を半角スペース区切りで入力してください。"},
                                       {"card"=>"S9S10 S11 S12 S13", "msg"=>"5つのカード指定文字を半角スペース区切りで入力してください。"}
                                      ]
                          }
      end

      it 'リクエストが201 Created となること' do
        expect(response).to be_success
        expect(response.status).to eq(201)
      end
      it '期待した JSON を返すこと' do
        expect(@json).to eq @expected_json
      end
    end

    context 'Common_validation 1 にはじかれる（半角スペース以外で区切っている）' do
      before do
        request       = "{\"cards\":
                                     [
                                      \"S9　S10 S11 S12 S13\",
                                      \"S9  S10 S11 S12 S13\",
                                      \"S9/S10 S11 S12 S13\",
                                      \"S9ㅤS10 S11 S12 S13\",
                                      \" S9 S10 S11 S12 S13\"
                                     ]
                          }"

        post '/api/v1/poker_hands', params: request
        @json          = JSON.parse(response.body)
        @expected_json = {"error" => [
                                      {"card"=>"S9　S10 S11 S12 S13", "msg"=>"5つのカード指定文字を半角スペース区切りで入力してください。"},
                                      {"card"=>"S9  S10 S11 S12 S13", "msg"=>"5つのカード指定文字を半角スペース区切りで入力してください。"},
                                      {"card"=>"S9/S10 S11 S12 S13", "msg"=>"5つのカード指定文字を半角スペース区切りで入力してください。"},
                                      {"card"=>"S9ㅤS10 S11 S12 S13", "msg"=>"5つのカード指定文字を半角スペース区切りで入力してください。"},
                                      {"card"=>" S9 S10 S11 S12 S13", "msg"=>"5つのカード指定文字を半角スペース区切りで入力してください。"}
                                     ]
                          }
      end

      it 'リクエストが201 Created となること' do
        expect(response).to be_success
        expect(response.status).to eq(201)
      end
      it '期待した JSON を返すこと' do
        expect(@json).to eq @expected_json
      end
    end


    # Common_Validator 2 にはじかれるケース #######################################################################################################################################################################################

    context 'Common_validation 2 にはじかれる（スートが指定文字でない）' do
      before do
        request       = "{\"cards\":
                                     [
                                      \"9 S10 S11 S12 S13\",
                                      \"S9 Ｓ10 S11 S12 S13\",
                                      \"S9 S10 s11 S12 S13\",
                                      \"S9 S10 S11 A12 S13\",
                                      \"S9 S10 S11 S12 ё13\",
                                      \"@9 SS10 S11 S12 S13\"
                                     ]
                           }"

        post '/api/v1/poker_hands', params: request
        @json          = JSON.parse(response.body)
        @expected_json = {"error" => [
                                      {"card"=>"9 S10 S11 S12 S13", "msg"=>"1番目のカード指定文字が不正です。(9) ,半角英字大文字のスート（S,H,D,C）と数字（1〜13）の組み合わせでカードを指定してください。"},
                                      {"card"=>"S9 Ｓ10 S11 S12 S13", "msg"=>"2番目のカード指定文字が不正です。(Ｓ10) ,半角英字大文字のスート（S,H,D,C）と数字（1〜13）の組み合わせでカードを指定してください。"},
                                      {"card"=>"S9 S10 s11 S12 S13", "msg"=>"3番目のカード指定文字が不正です。(s11) ,半角英字大文字のスート（S,H,D,C）と数字（1〜13）の組み合わせでカードを指定してください。"},
                                      {"card"=>"S9 S10 S11 A12 S13", "msg"=>"4番目のカード指定文字が不正です。(A12) ,半角英字大文字のスート（S,H,D,C）と数字（1〜13）の組み合わせでカードを指定してください。"},
                                      {"card"=>"S9 S10 S11 S12 ё13", "msg"=>"5番目のカード指定文字が不正です。(ё13) ,半角英字大文字のスート（S,H,D,C）と数字（1〜13）の組み合わせでカードを指定してください。"},
                                      {"card"=>"@9 SS10 S11 S12 S13", "msg"=>"1番目のカード指定文字が不正です。(@9) ,2番目のカード指定文字が不正です。(SS10) ,半角英字大文字のスート（S,H,D,C）と数字（1〜13）の組み合わせでカードを指定してください。"}
                                     ]
                          }
      end

      it 'リクエストが201 Created となること' do
        expect(response).to be_success
        expect(response.status).to eq(201)
      end
      it '期待した JSON を返すこと' do
        expect(@json).to eq @expected_json
      end
    end


    context 'Common_validation 2 にはじかれる（数字が指定文字でない）' do
      before do
        request       = "{\"cards\":
                                     [
                                      \"S S10 S11 S12 S13\",
                                      \"S９ S10 S11 S12 S13\",
                                      \"S@ S10 S11 S12 S13\",
                                      \"SA S10 S11 S12 S13\",
                                      \"Sё S10 S11 S12 S13\",
                                      \"S14 S10 S11 S12 S13\",
                                      \"S09 S10 S11 S12 S13\",
                                      \"S1.1 S10 S11 S12 S13\",
                                      \"S2*3 S10 S11 S12 S13\"
                                     ]
                           }"

        post '/api/v1/poker_hands', params: request
        @json          = JSON.parse(response.body)
        @expected_json = {"error" => [
                                      {"card"=>"S S10 S11 S12 S13", "msg"=>"1番目のカード指定文字が不正です。(S) ,半角英字大文字のスート（S,H,D,C）と数字（1〜13）の組み合わせでカードを指定してください。"},
                                      {"card"=>"S９ S10 S11 S12 S13", "msg"=>"1番目のカード指定文字が不正です。(S９) ,半角英字大文字のスート（S,H,D,C）と数字（1〜13）の組み合わせでカードを指定してください。"},
                                      {"card"=>"S@ S10 S11 S12 S13", "msg"=>"1番目のカード指定文字が不正です。(S@) ,半角英字大文字のスート（S,H,D,C）と数字（1〜13）の組み合わせでカードを指定してください。"},
                                      {"card"=>"SA S10 S11 S12 S13", "msg"=>"1番目のカード指定文字が不正です。(SA) ,半角英字大文字のスート（S,H,D,C）と数字（1〜13）の組み合わせでカードを指定してください。"},
                                      {"card"=>"Sё S10 S11 S12 S13", "msg"=>"1番目のカード指定文字が不正です。(Sё) ,半角英字大文字のスート（S,H,D,C）と数字（1〜13）の組み合わせでカードを指定してください。"},
                                      {"card"=>"S14 S10 S11 S12 S13", "msg"=>"1番目のカード指定文字が不正です。(S14) ,半角英字大文字のスート（S,H,D,C）と数字（1〜13）の組み合わせでカードを指定してください。"},
                                      {"card"=>"S09 S10 S11 S12 S13", "msg"=>"1番目のカード指定文字が不正です。(S09) ,半角英字大文字のスート（S,H,D,C）と数字（1〜13）の組み合わせでカードを指定してください。"},
                                      {"card"=>"S1.1 S10 S11 S12 S13", "msg"=>"1番目のカード指定文字が不正です。(S1.1) ,半角英字大文字のスート（S,H,D,C）と数字（1〜13）の組み合わせでカードを指定してください。"},
                                      {"card"=>"S2*3 S10 S11 S12 S13", "msg"=>"1番目のカード指定文字が不正です。(S2*3) ,半角英字大文字のスート（S,H,D,C）と数字（1〜13）の組み合わせでカードを指定してください。"}
                                     ]
                          }
      end

      it 'リクエストが201 Created となること' do
        expect(response).to be_success
        expect(response.status).to eq(201)
      end
      it '期待した JSON を返すこと' do
        expect(@json).to eq @expected_json
      end
    end

    context 'Common_validation 2 にはじかれる（スートと数字の間に文字が入る）' do
      before do
        request       = "{\"cards\":
                                     [
                                      \"S@9 S10 S11 S12 S13\"
                                     ]
                           }"

        post '/api/v1/poker_hands', params: request
        @json          = JSON.parse(response.body)
        @expected_json = {"error" => [
                                      {"card"=>"S@9 S10 S11 S12 S13", "msg"=>"1番目のカード指定文字が不正です。(S@9) ,半角英字大文字のスート（S,H,D,C）と数字（1〜13）の組み合わせでカードを指定してください。"}
                                     ]
                          }
      end

      it 'リクエストが201 Created となること' do
        expect(response).to be_success
        expect(response.status).to eq(201)
      end
      it '期待した JSON を返すこと' do
        expect(@json).to eq @expected_json
      end
    end

    # Common_Validationにはじかれるエラーが混在しているケース #######################################################################################################################################################################################

    context 'Common_validation 1とCommon_validation 2にはじかれるエラーが混在している場合、前者が優先される' do
      before do
        request       = "{\"cards\":
                                     [
                                      \"s9 SP S11 S12S13\"
                                     ]
                           }"

        post '/api/v1/poker_hands', params: request
        @json          = JSON.parse(response.body)
        @expected_json = {"error" => [
                                      {"card"=>"s9 SP S11 S12S13", "msg"=>"5つのカード指定文字を半角スペース区切りで入力してください。"}
                                      ]
                          }

      end

      it 'リクエストが201 Created となること' do
        expect(response).to be_success
        expect(response.status).to eq(201)
      end
      it '期待した JSON を返すこと' do
        expect(@json).to eq @expected_json
      end
    end


    context 'エラーのあるものとないものが混在している場合' do
      before do
        request       = "{\"cards\":
                                     [
                                      \"S9S10 S11 S12 S13\",
                                      \"S1.1 S10 S11 S12 S13\",
                                      \"S9 S10 S11 S12 S13\",
                                      \"01 S10 S11 S12 S13\",
                                      \"S12 H12 C12 D12 C5\"
                                     ]
                           }"

        post '/api/v1/poker_hands', params: request
        @json          = JSON.parse(response.body)
        @expected_json = {"error" => [
                                      {"card"=>"S9S10 S11 S12 S13", "msg"=>"5つのカード指定文字を半角スペース区切りで入力してください。"},
                                      {"card"=>"S1.1 S10 S11 S12 S13", "msg"=>"1番目のカード指定文字が不正です。(S1.1) ,半角英字大文字のスート（S,H,D,C）と数字（1〜13）の組み合わせでカードを指定してください。"},
                                      {"card"=>"01 S10 S11 S12 S13", "msg"=>"1番目のカード指定文字が不正です。(01) ,半角英字大文字のスート（S,H,D,C）と数字（1〜13）の組み合わせでカードを指定してください。"}
                                      ],
                         "result" => [
                                      {"card"=>"S9 S10 S11 S12 S13", "hand"=>"ストレートフラッシュ", "best"=>"true"},
                                      {"card"=>"S12 H12 C12 D12 C5", "hand"=>"フォー・オブ・ア・カインド", "best"=>"false"}
                                      ]
                         }
      end

      it 'リクエストが201 Created となること' do
        expect(response).to be_success
        expect(response.status).to eq(201)
      end
      it '期待した JSON を返すこと' do
        expect(@json).to eq @expected_json
      end
    end



  end
end


