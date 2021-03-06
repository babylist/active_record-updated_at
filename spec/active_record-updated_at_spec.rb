RSpec.describe ActiveRecord::UpdatedAt do
  let(:reloaded) { User.find(user.id) }

  let!(:user) { User.create!(name: "test") }
  let!(:timestamp) { 1.day.ago }

  describe "#enabled" do
    it "can be nested with disable blocks" do
      expect(described_class).to be_enabled

      described_class.disable do
        expect(described_class).not_to be_enabled
        described_class.enable { expect(described_class).to be_enabled }
        expect(described_class).not_to be_enabled
      end

      expect(described_class).to be_enabled
    end
  end

  describe "#update_all" do
    context "with an array" do
      it "touches updated_at" do
        Timecop.freeze(timestamp) { User.update_all(["name = ?", "changed"]) }
        expect(reloaded.name).to eq("changed")
        expect(reloaded.updated_at.to_s).to eq(timestamp.to_s)
      end

      it "does not touch updated_at if already specified" do
        User.update_all(["name = ?, updated_at = ?", "changed", timestamp])
        expect(reloaded.name).to eq("changed")
        expect(reloaded.updated_at.to_s).to eq(timestamp.to_s)
      end

      it "does not touch updated_at with workaround method" do
        described_class.disable { User.update_all(["name = ?", "changed"]) }
        expect(reloaded.name).to eq("changed")
        expect(reloaded.updated_at).to eq(user.updated_at)
      end
    end

    context "with a hash" do
      it "touches updated_at" do
        Timecop.freeze(timestamp) { User.update_all(name: "changed") }
        expect(reloaded.name).to eq("changed")
        expect(reloaded.updated_at.to_s).to eq(timestamp.to_s)
      end

      it "does not touch updated_at if already specified" do
        User.update_all(name: "changed", updated_at: timestamp)
        expect(reloaded.name).to eq("changed")
        expect(reloaded.updated_at.to_s).to eq(timestamp.to_s)
      end

      it "does not touch updated_at with workaround method" do
        described_class.disable { User.update_all(name: "changed") }
        expect(reloaded.name).to eq("changed")
        expect(reloaded.updated_at).to eq(user.updated_at)
      end
    end

    context "with a string" do
      it "touches updated_at" do
        Timecop.freeze(timestamp) { User.update_all("name = 'changed'") }
        expect(reloaded.name).to eq("changed")
        expect(reloaded.updated_at.to_s).to eq(timestamp.to_s)
      end

      it "does not touch updated_at if already specified" do
        formatted_timestamp = timestamp.iso8601(6)
        User.update_all("name = 'changed', updated_at = '#{formatted_timestamp}'")
        expect(reloaded.name).to eq("changed")
        expect(reloaded.updated_at.to_s).to eq(timestamp.to_s)
      end

      it "does not touch updated_at with workaround method" do
        described_class.disable { User.update_all("name = 'changed'") }
        expect(reloaded.name).to eq("changed")
        expect(reloaded.updated_at).to eq(user.updated_at)
      end
    end
  end

  describe "#update_column" do
    it "touches updated_at" do
      Timecop.freeze(timestamp) { user.update_column(:name, "changed") }
      expect(reloaded.name).to eq("changed")
      expect(reloaded.updated_at.to_s).to eq(timestamp.to_s)
    end

    it "does not touch updated_at if already specified" do
      user.update_column(:updated_at, timestamp)
      expect(reloaded.updated_at.to_s).to eq(timestamp.to_s)
    end

    it "does not touch updated_at with workaround method" do
      described_class.disable { user.update_column(:name, "changed") }
      expect(reloaded.name).to eq("changed")
      expect(reloaded.updated_at).to eq(user.updated_at)
    end
  end

  describe "#update_columns" do
    it "touches updated_at" do
      Timecop.freeze(timestamp) { user.update_columns(name: "changed") }
      expect(reloaded.name).to eq("changed")
      expect(reloaded.updated_at.to_s).to eq(timestamp.to_s)
    end

    it "does not touch updated_at if already specified" do
      user.update_columns(name: "changed", updated_at: timestamp)
      expect(reloaded.name).to eq("changed")
      expect(reloaded.updated_at.to_s).to eq(timestamp.to_s)
    end

    it "does not touch updated_at with workaround method" do
      described_class.disable { user.update_columns(name: "changed") }
      expect(reloaded.name).to eq("changed")
      expect(reloaded.updated_at).to eq(user.updated_at)
    end
  end
end
