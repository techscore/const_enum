# coding: utf-8

module ConstEnum
  module ActiveRecord
    
    mattr_accessor :label_suffix, :i18n
    # ラベル名メソッドに付与するサフィックス
    self.label_suffix = '_label'
    # ラベル名にi18nを使用するかどうか
    self.i18n = true

    module ClassMethods
      # 定数クラス、定数ラベルアクセサ、named_scope、predicate methodを作成します
      # 
      # = arguments
      # mod_name: 定義されるクラスの名前です
      # options: 
      #  :scope         named_scopeを定義します。default: true
      #  :predicate     属性値の検証メソッドを定義します。default: true
      #  :prefix        scope, predicate を作成する際のprefixを指定します。default: "#{mod_name.downcase}_"
      #
      # = exapmle
      # 
      # class Hoge < ActiveRecord::Base
      #   const :STATUS do
      #     ENABLE    1, '有効'
      #     DISABLE   0, '無効'
      #     def code
      #       '%05d'%value
      #     end
      #   end
      # end
      # 
      # Hoge::STATUS::ENABLE # 1
      # Hoge::STATUS.ENABLE.value # 1
      # Hoge::STATUS.ENABLE.label # "有効"
      # Hoge::STATUS.ENABLE.code # 00001
      # Hoge.crate(:name => '有効なHOGE', :status => Hoge::STATUS::ENABLE)
      # Hoge.crate(:name => '無効なHOGE', :status => Hoge::STATUS::DISABLE)
      # enable_hoge = Hoge.status_enable.first
      # enable_hoge.name # "有効なHOGE"
      # enable_hoge.status_label # "有効"
      # newhoge = Hoge.new(:name => '新しいHOGE', :status => Hoge::STATUS::ENABLE)
      # newhoge.status_enable? # true
      # newhoge.status_disable? # false
      # form_for newhoge do |f|
      #   f.collection_select(:status, Hoge::STATUS, :value, :label)
      #   f.collection_select(:status, Hoge::STATUS, :value, :code)
      # end
      #
      def const(clazz_name, options = {}, &block)
        clazz_name = clazz_name.to_s
        default = {:label_suffix => ConstEnum::ActiveRecord.label_suffix,:scope => true, :predicate => true, :attr=>clazz_name.downcase, :prefix => "#{clazz_name.downcase}_", :validation => false, :allow_blank => true, :i18n => true}
        options = default.merge(options.symbolize_keys)
        attr = options[:attr]
        if ConstEnum::ActiveRecord.i18n and options[:i18n]
          clazz = const_enum do
            include ConstEnum::WithI18n
            class_eval(&block)
          end
          clazz.i18n_options[:key] = [clazz.i18n_options[:key], self.name.underscore, attr].join('.')
          clazz.i18n_options.merge!(ConstEnum::ActiveRecord.i18n) if Hash === ConstEnum::ActiveRecord.i18n
          clazz.i18n_options.merge!(options[:i18n]) if Hash === options[:i18n]
        else
          clazz = const_enum(&block)
        end
        
        const_set(clazz_name, clazz)
        if options[:label_suffix]
          class_eval <<-"EOS", __FILE__, __LINE__
            def #{attr}#{options[:label_suffix]}
              #{clazz_name}[#{attr}].try(:label)
            end
            def #{attr}#{options[:label_suffix]}_was
              #{clazz_name}[#{attr}_was].try(:label)
            end
          EOS
        end
        if options[:scope]
          clazz.each do |obj|
            key =  clazz.key(obj.value).to_s
            class_eval <<-"EOS", __FILE__, __LINE__
              scope :#{options[:prefix]}#{key.downcase}, lambda { {:conditions => {'#{attr}' => #{clazz_name}::#{key} } }}
            EOS
          end
        end
        if options[:predicate]
          clazz.each do |obj|
            key = clazz.key(obj.value).to_s
            class_eval <<-"EOS", __FILE__, __LINE__
              def #{options[:prefix]}#{key.downcase}?
                #{attr} == #{clazz_name}::#{key}
              end
              def was_#{options[:prefix]}#{key.downcase}?
                #{attr}_was == #{clazz_name}::#{key}
              end
            EOS
          end
        end
        if options[:validation]
          validates attr.to_sym, :inclusion => {:in => clazz}, :allow_blank => (!!options[:allow_blank])
        end
        clazz
      end
    end
  end
end

ActiveSupport.on_load(:active_record) do
  ::ActiveRecord::Base.send :extend,  ConstEnum::ActiveRecord::ClassMethods
end