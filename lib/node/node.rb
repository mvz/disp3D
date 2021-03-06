require 'disp3D'

class Class
  # use this instead of attr_accessor.
  # if attribute is changed call Node#update
  def attr_for_disp(attribute)
    define_method "#{attribute}=" do |value|
      instance_variable_set("@#{attribute}", value)
      update_for_display
    end
    define_method attribute do
      instance_variable_get "@#{attribute}"
    end
  end
end

module Disp3D
  class Node
    attr_for_disp :pre_translate # GMath3D::Vector3
    attr_for_disp :rotate # GMath3D::Quat
    attr_for_disp :post_translate # GMath3D::Vector3

    attr_reader :name
    attr_reader :instance_id
    attr_reader :parents # Array of Node

    def initialize(name = nil)
      Util3D.check_arg_type(Symbol, name, true)
      @parents = []
      @instance_id = gen_instance_id()
      @name = name
      NodeDB.add(self)
    end

    def pre_draw
      GL.PushMatrix()
      GL.Translate(pre_translate.x, pre_translate.y, pre_translate.z) if(@pre_translate)
      GL.MultMatrix(@rotate.to_array) if(@rotate)
      GL.Translate(post_translate.x, post_translate.y, post_translate.z) if(@post_translate)
    end

    def post_draw
      GL.PopMatrix()
    end

    def ancestors
      rtn_ancestors_ary = []
      return ancestors_inner(rtn_ancestors_ary)
    end

protected
    def create(hash)
      Util3D.check_key_arg(hash, :type)
      geom_arg = hash[:geom]
      name_arg = hash[:name]
      clazz = eval "Node" + hash[:type].to_s
      # node leaf constractor need 2 args
      if( clazz < Disp3D::NodeLeaf )
        new_node = clazz.new(geom_arg, name_arg)
      elsif( clazz <= Disp3D::NodeCollection )
        new_node = clazz.new(name_arg)
      else
        raise
      end
      hash.delete(:geom)
      hash.delete(:type)
      hash.delete(:name)
      new_node.update(hash)
      return new_node
    end

    # cannnot contains key :type and :name. they cannot be set
    def update(hash)
      if(hash.include?(:name))
        node = NodeDB.find_by_name(hash[:name])
        hash.delete(:name)
        if(node.kind_of?(Array))
          node.each do |item|
            item.update(hash)
          end
        elsif(!node.nil?)
          node.update(hash)
        end
      elsif
        hash.each do | key, value |
          next if( key == :type or key ==:name) # cannot change name and type
          self.send( key.to_s+"=", value)
        end
      end
    end

    def delete(node_name)
      Util3D::check_arg_type(Symbol, node_name)
      node = NodeDB.find_by_name(node_name)

      if(node.kind_of?(Array))
        node.each do | node_ele |
         remove_from_parents(node_ele)
        end
      elsif(!node.nil?)
         remove_from_parents(node)
      end
      NodeDB.delete_by_name(node_name)
    end

    def remove_from_parents(node)
      Util3D::check_arg_type(Node, node)
      node.parents.each do |parent|
        parent.remove_child_by_node(node)
      end
    end

    def box_transform(box)
      box = box.translate(@pre_translate) if(@pre_translate)
      box = box.rotate(@rotate) if(@rotate)
      box = box.translate(@post_translate) if(@post_translate)
      return box
    end

    def ancestors_inner(rtn_ancestors_ary)
      parents.each do |parent|
        if(!rtn_ancestors_ary.include?(parent.instance_id))
          rtn_ancestors_ary.push(parent.instance_id)
          parent.ancestors_inner(rtn_ancestors_ary)
        end
      end
      return rtn_ancestors_ary
    end

private
    def gen_instance_id
      return GL.GenLists(1)
    end
  end

  class NodeDB
    def self.add(node)
      Util3D.check_arg_type(Node, node)
      @node_db ||= Hash.new()
      key = node.name
      if(!@node_db.key?(key))
        @node_db[key] = node
      elsif(@node_db[key].kind_of?(Node))
        @node_db[key] = [@node_db[key], node]
      elsif(@node_db[key].kind_of?(Array))
        @node_db[key].push(node)
      else
        raise
      end
    end

    def self.find_by_name(node_name)
      @node_db ||= Hash.new()
      Util3D.check_arg_type(Symbol, node_name)
      return @node_db[node_name]
    end

    def self.delete_by_name(node_name)
      return if @node_db.nil? || node_name.nil?
      @node_db[node_name] = nil
    end
  end
end
