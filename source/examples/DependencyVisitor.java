
import com.google.javascript.jscomp.NodeUtil;
import com.google.javascript.rhino.Node;
import com.google.javascript.rhino.Token;

public class DependencyVisitor implements NodeUtil.Visitor {

    public final Set<String>
            provides = new HashSet<String>(),
            requires = new HashSet<String>();

    @Override
    public void visit(Node node) {
        switch (node.getType()) {
            // all x() statements
            case Token.CALL:
                visitCall(node);
                break;
        }
    }

    /**
     * gets a call node that is in the form x(y), first we check that x is "goog.require" or "goog.provide" and
     * if that is the case, we capture the first argument to them.
     */
    private void visitCall(Node callNode) {
        if (node.hasChildren()) {
            String getterNode = node.getFirstChild();
            switch (getterNode.getQualifiedName()) {
                case "goog.provide":
                    provides.add(getterNode.getNextSibling().getString());
                    break;
                case "goog.require":
                    requires.add(getterNode.getNextSibling().getString());
                    break;
            }
        }
    }
}
