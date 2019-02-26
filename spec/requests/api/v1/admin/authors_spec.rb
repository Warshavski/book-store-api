require 'rails_helper'

RSpec.describe Api::V1::Admin::AuthorsController, type: :request do
  before do
    subject.class.skip_before_action :authenticate_user!, raise: false
    allow_any_instance_of(subject.class).to receive(:current_user).and_return(create(:user, :admin))
  end

  let!(:base_url) { '/api/v1/admin/authors' }

  let(:author)        { create(:author) }
  let(:author_url)    { "#{base_url}/#{author.id}" }
  let(:author_params) { build(:author_params) }

  describe 'GET #index' do
    let!(:authors) { create_list(:author_seq, 10) }

    context 'unsorted authors collection' do
      before(:each) { get base_url }

      it 'responds with a 200 status' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns correct quantity' do
        expect(body_as_json[:data].count).to be(10)
      end

      it 'responds with json-api format' do
        expect(response.body).to look_like_json
        expect(body_as_json[:data].first.keys).to match_array(%w[id type attributes])
      end

      it 'returns correct attributes collection' do
        actual_keys = body_as_json[:data].first[:attributes].keys
        expected_keys = %w[biography first_name last_name born_in died_in created_at updated_at]

        expect(actual_keys).to match_array(expected_keys)
      end
    end

    context 'filtered authors collection' do
      let(:book) { create(:book, authors: authors[0..2]) }

      it 'returns filtered collection by search' do
        get "#{base_url}?search=ln-v7"

        actual_data = body_as_json[:data]

        expect(actual_data.count).to be(1)
        expect(actual_data.last[:attributes][:last_name]).to eq('ln-v7')
      end

      it 'returns filtered collection by book' do
        get "#{base_url}?book_id=#{book.id}"

        actual_data = body_as_json[:data]

        expect(actual_data.count).to be(3)
        expect(actual_data.last[:attributes][:last_name]).to eq('ln-v3')
      end

      it 'returns filtered collection by book and search' do
        get "#{base_url}?book_id=#{book.id}&search=ln-v2"

        actual_data = body_as_json[:data]

        expect(actual_data.count).to be(1)
        expect(actual_data.first[:attributes][:last_name]).to eq('ln-v2')
      end

      it 'returns filtered collection by page' do
        allow(Booky.config.pagination).to receive(:limit).and_return(5)

        get "#{base_url}?page=2"

        actual_data = body_as_json[:data]

        expect(actual_data.count).to be(5)
        expect(actual_data.first[:attributes][:last_name]).to eq('ln-v6')
      end

      it 'returns filtered collection by limit' do
        get "#{base_url}?limit=5"

        actual_data = body_as_json[:data]

        expect(actual_data.count).to be(5)
      end

      it 'returns filtered collection by limit and page' do
        get "#{base_url}?limit=5&page=2"

        actual_data = body_as_json[:data]

        expect(actual_data.count).to be(5)
        expect(actual_data.first[:attributes][:last_name]).to eq('ln-v6')
      end
    end

    context 'sorted authors collection' do
      it 'returns sorted collection by recently_created' do
        get "#{base_url}?sort=created_asc"

        expect(body_as_json[:data].last[:attributes][:first_name]).to eq('fn-v10')
      end

      it 'returns sorted collection by last_created' do
        get "#{base_url}?sort=created_desc"

        expect(body_as_json[:data].last[:attributes][:first_name]).to eq('fn-v1')
      end

      it 'returns sorted collection by first_name ascending' do
        get "#{base_url}?sort=first_name_asc"

        expect(body_as_json[:data].last[:attributes][:first_name]).to eq('fn-v9')
      end

      it 'returns sorted collection by first_name descending' do
        get "#{base_url}?sort=first_name_desc"

        expect(body_as_json[:data].last[:attributes][:first_name]).to eq('fn-v1')
      end

      it 'returns sorted collection by last_name ascending' do
        get "#{base_url}?sort=last_name_asc"

        expect(body_as_json[:data].last[:attributes][:last_name]).to eq('ln-v9')
      end

      it 'returns sorted collection by last_name descending' do
        get "#{base_url}?sort=last_name_desc"

        expect(body_as_json[:data].last[:attributes][:last_name]).to eq('ln-v1')
      end
    end
  end

  describe 'GET #show' do
    context 'valid request' do
      before(:each) { get author_url }

      it 'responds with a 200 status' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns correct data format' do
        actual_keys = body_as_json[:data][:attributes].keys
        expected_keys = %w[biography first_name last_name born_in died_in created_at updated_at]

        expect(actual_keys).to match_array(expected_keys)
      end

      it 'returns correct expected data' do
        expect(body_as_json[:data][:attributes][:last_name]).to eq(author.last_name)
      end
    end

    context 'invalid request' do
      it 'returns 404 response on not existed author' do
        get "#{base_url}/wat-author?"

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST #create' do
    context 'author presence' do
      it { expect { post base_url, params: { data: author_params } }.to change(Author, :count).by(1) }
    end

    context 'valid request' do
      before(:each) { post base_url, params: { data: author_params } }

      it 'responds with a 201 status' do
        expect(response).to have_http_status(:created)
      end

      it 'responds with a correct model format' do
        actual_keys = body_as_json[:data][:attributes].keys
        expected_keys = %w[biography first_name last_name born_in died_in created_at updated_at]

        expect(actual_keys).to match_array(expected_keys)
      end

      it 'returns created model' do
        expect(body_as_json[:data][:attributes][:first_name]).to eq(author_params.dig(:attributes, :first_name))
      end
    end

    context 'invalid request' do
      it 'responds with a 400 status on not presented params' do
        post base_url, params: nil

        expect(response).to have_http_status(:bad_request)
      end

      it 'responds with a 400 status on not request without params' do
        post base_url

        expect(response).to have_http_status(:bad_request)
      end

      it 'responds with a 422 status on invalid first_name' do
        author_params[:attributes][:first_name] = nil
        post base_url, params: { data: author_params }

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'responds with a 422 status on invalid last_name' do
        author_params[:attributes][:last_name] = nil
        post base_url, params: { data: author_params }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PUT #update' do
    context 'valid request' do
      before(:each) { put author_url, params: { data: author_params } }

      it 'responds with a 204 status' do
        expect(response).to have_http_status(:no_content)
      end

      it 'updates a model' do
        expect(author.reload.last_name).to eq(author_params.dig(:attributes,:last_name))
      end
    end

    context 'invalid request' do
      it 'responds with a 404 status not existed author' do
        put "#{base_url}/wat-author?", params: { data: author_params }

        expect(response).to have_http_status(:not_found)
      end

      it 'responds with a 400 status on request with empty params' do
        put author_url, params: nil

        expect(response).to have_http_status(:bad_request)
      end

      it 'responds with a 400 status on request without params' do
        put author_url

        expect(response).to have_http_status(:bad_request)
      end

      it 'responds with a 422 status on request with not valid last_name' do
        author_params[:attributes][:last_name] = nil
        put author_url, params: { data: author_params }

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'responds with a 422 status on request with not valid first_name' do
        author_params[:attributes][:first_name] = nil
        put author_url, params: { data: author_params }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'responds with a 204 status' do
      delete author_url

      expect(response).to have_http_status(:no_content)
    end

    it 'responds with a 404 status not existed author' do
      delete "#{base_url}/wat_author?"

      expect(response).to have_http_status(:not_found)
    end

    it 'deletes author' do
      expect { delete author_url }.to change(Author, :count).by(0)
    end
  end
end